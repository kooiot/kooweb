local function get_full_path(path)
	local path = app.config.static..'releases/'..path
	os.execute('mkdir -p '..path)
	return path
end

local function save_app(path, file, version)
	local path = get_full_path(path)
	filename = path..'/latest.lpk'
	vfilename = path..'/'..version..'.lpk'
	print(filename, vfilename)
	local f, err = io.open(filename, 'w+')
	if f then
		f:write(file.contents)
		f:close()
		os.execute('cp '..filename..' '..vfilename)
		return true
	end
	return nil, err
end

local TYPES = {'app', 'app.io', 'app.io.config'}
local CATES = {'Industrial', 'Home Automation'}

return {
	get = function(req, res)
		if lwf.ctx.user then
			res:ltp('app/new.html')
		else
			lwf.exit(404)
		end
	end,
	post = function(req, res)
		req:read_body()
		if lwf.ctx.user then
			local file = req.post_args['file']
			local appname = req.post_args['appname']
			local apptype = req.post_args['apptype']
			local version = req.post_args['version']
			local category = req.post_args['category']
			local depends = req.post_args['depends']
			local desc = req.post_args['desc']
			version = version:match('(%d+%.%d+%.%d+)')
			local err = 'Error:'
			if file and appname and version then 
				local version = version or '1.0.0'
				print(appname..'-'..apptype..'-'..category)
				local apptype = TYPES[tonumber(apptype) or 1]
				local category = CATES[tonumber(category) or 1]
				print(appname..'-'..apptype..'-'..category)
				local username = lwf.ctx.user.username
				local db = app.model:get('db')
				db:init()
				local info = db:get_app(username, appname)
				local path = username..'/'..appname
				local r, err = save_app(path, file, version)
				if r then
					if not info then
						db:create_app(username, appname, {path=path, name=appname, version=version, apptype=apptype, category=category, desc=desc, depends=depends})
					else
						db:update_app(username, appname, {path=path, name=appname, version=version, apptype=apptype, category=category, desc=desc, depends=depends})
					end
				end
				db:close()
				--res:redirect('/app/detail/'..path)
				res:write('/app/detail/'..path)
			else
				if not appname then
					err = err..'\n Application name not specified'
				end
				if not version then
					err = err..'\n Application version not specified or incorrect'
				end
				res:ltp('app/new.html', {app=app, lwf=lwf, err=err})
			end
			--
		else
			res:redirect('/user/login')
		end
	end
}
