return {
	get = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		--[[
		local db = app.model:get('mail')
		db:init()
		local username = lwf.ctx.user.username
		local mails = db:list(username)
		]]--
		res:ltp('user/mail.html', {lwf=lwf, app=app, mails={}})
	end,
	post = function(req, res)
		if not lwf.ctx.user then
			return lwf.exit(403)
		end

		req:read_body()

		local db = app.model:get('mail')
		db:init()

		local action = req:get_arg('action')
		if action then
			local un = lwf.ctx.user.username
			local r, err
			if action == 'send' then
				local touser = req:get_arg('touser')
				local content = req:get_arg('alias')
				r, err = db:send(un, touser, content)
			elseif action == 'delete' then
				local id = req:get_arg('id')
				r, err = db:delete(un, id)
			else
				err = 'Action is not known to us'
			end

			if not r then
				res:write(err)
				return lwf.set_status(403)
			else
				res:write('OK')
			end
		else
			res:write('No action sepecified')
			return lwf.set_status(403)
		end
	end
}
