local get_info = function(req, res, path, err)
	if not lwf.ctx.user then
		res:redirect('/')
	end

	local db = app.model:get('db')
	db:init()
	local username, appname = path:match('^([^/]+)/(.+)$')
	local appinfo = db:get_app(username, appname)
	appinfo.username = username
	db:close()

	res:ltp('app/modify.html', {lwf=lwf, app=app, info=appinfo, err = err})	
end

return {
	get = get_info,
	post = function(req, res)
		req:read_body()
		if lwf.ctx.user then
			local err = nil
			local action = req.post_args['action'] or 'icon'
			if action == 'icon' then
				local file = req.post_args['file']
				local path = req.post_args['path']
				if path and path:match('([^/]+)/.+') == lwf.ctx.user.username then
					local file_path = app.config.static..'releases/'
					local filename = file_path..path..'/icon.jpg'
					local f
					f, err = io.open(filename, 'w+')
					if f then
						f:write(file.contents)
						f:close()
					end
				else
					err = 'Incorrect path posted '..path
				end
				get_info(req, res, path, err)
			else
				res:redirect('/')
			end
		else
			res:redirect('/user/login')
		end
	end,
}
