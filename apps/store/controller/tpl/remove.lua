return {
	post = function(req, res)
		req:read_body()

		local db = app.model:get('db')
		db:init()

		local username = lwf.ctx.user and lwf.ctx.user.username or nil

		--[[
		-- Do we need this?
		local authkey = req.headers.authkey
		local err = nil
		if authkey then
			username, err = db:check_user_key(authkey) 
		end
		]]--

		if not username then 
			print('User not loged in')
			lwf.exit(403)
			return
		end
		
		local app_path = req:get_arg('app_path')
		if not app_path then
			print('Incorrect post args')
			lwf.exit(403)
			return
		end

		local tpl_path = req:get_arg('path')
		print(tpl_path)
		local ns, name = tpl_path:match('^([^/]+)/(.+)$')
		print(ns,name)

		if not ns or ns ~= username then
			print('NS not matched', ns, username)
			lwf.exit(403)
			return
		end

		local r, err = db:del_tpl(app_path, tpl_path)

		if r then
			res.headers['Content-Type'] = 'text; charset=utf-8'
			res:write('DONE')
		else
			res:write('ERROR: '..err)
		end
	end
}
