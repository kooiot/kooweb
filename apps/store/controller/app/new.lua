local function get_full_path(path)
	local filename = app.config.static..'releases/'..path
	os.execute('mkdir -p '..filename)
	filename = filename..'/latest.lpk'
	-- No version detection?
	return filename
end

local function save_app(path, file)
	local filename = get_full_path(path)
	print(filename)
	local f, err = io.open(filename, 'w+')
	if f then
		f:write(file.content)
		f:close()
		return true
	end
	return nil, err
end

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
			if file and appname then 
				local username = lwf.ctx.user.username
				local db = app.model:get('db')
				db:init()
				local info = db:get_app(username, appname)
				if not info then
					local path = username..'/'..appname
					local r, err = save_app(path, file)
					if r then
						db:create_app(username, appname, {path=path})
					end
				end
			end
			res:ltp('app/new.html')
			--
		else
			lwf.exit(404)
		end
	end
}
