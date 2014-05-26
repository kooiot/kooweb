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
			local version = req.post_args['version']
			local depends = req.post_args['depends']
			version = version:match('(%d+%.%d+%.%d+)')
			local err = nil
			if file and appname and version then 
				local action = req.post_args['action'] or 'new'
				local username = lwf.ctx.user.username
				local path = username..'/'..appname

				local db = app.model:get('db')
				db:init()
				local info = db:get_app(username, appname)
				if action == 'new' and not info then
					local category = req.post_args['category']
					local apptype = req.post_args['apptype']
					local desc = req.post_args['desc']
					local version = version or '1.0.0'

					local apptype = TYPES[tonumber(apptype) or 1]
					local category = CATES[tonumber(category) or 1]
					local r, err_f = save_app(path, file, version)
					if r then
						db:create_app(username, appname, {path=path, name=appname, version=version, apptype=apptype, category=category, desc=desc, depends=depends})
					else
						err = err_f
					end
				elseif action ~= 'new' and info then
					info.version = version
					info.depends = depends
					local r, err_f = save_app(path, file, version)
					if t then
						r, err_f = db:update_app(username, appname, info)
					end
					err = err_f
				else
					if action == 'new' then
						err = 'ERROR:<br> The application '..appname..' exists, If you want to upload a new version, go to'
						err = err .. '<a class="ui link" href="/app/modify/'..path..'"> Here </a>'
					else
						err = "The application "..appname.." not exists!!!!"
					end
				end
				db:close()
				err = err or ([[Uploaded successfully, details here <a class="ui link" href="/app/detail/]]..path..[["> Here </a>]])
				res:write(err)
			else
				err = "Error:"
				if not appname then
					err = err..'<br> Application name not specified'
				end
				if not version then
					err = err..'<br> Application version not specified or incorrect'
				end
				res:write(err)
				--res:ltp('app/new.html', {app=app, lwf=lwf, err=err})
			end
			--
		else
			res:redirect('/user/login')
		end
	end
}
