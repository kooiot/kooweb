return {
	get = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		local db = app.model:get('keys')
		db:init()
		local userkeys = db:list(lwf.ctx.user.username)
		res:ltp('user/keys.html', {lwf=lwf, app=app, userkeys=userkeys})
	end,
	post = function(req, res)
		if not lwf.ctx.user then
			return lwf.exit(403)
		end

		req:read_body()

		local key = req:get_arg('key')
		local action = req:get_arg('action')
		if key then
			local db = app.model:get('keys')
			db:init()

			local r, err
			if action == 'add' then
				r, err = db:add(lwf.ctx.user.username, key)
			elseif action == 'delete' then
				r, err = db:delete(lwf.ctx.user.username, key)
			end
			if not r then
				return res:write(err or 'No action')
			end
		end
		res:write('DONE')
	end
}
