return {
	get = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		local db = app.model:get('keys')
		db:init()
		local username = lwf.ctx.user.username
		local userkeys = db:list(username) or {}
		local alias_list = {}
		for _, key in ipairs(userkeys) do
			local r, err = db:alias(username, key)
			if r then
				alias_list[key] = r
			end
		end
		res:ltp('user/devkeys.html', {lwf=lwf, app=app, userkeys=userkeys, alias_list=alias_list})
	end,
	post = function(req, res)
		if not lwf.ctx.user then
			return lwf.exit(403)
		end

		req:read_body()

		local key = req:get_arg('key')
		local action = req:get_arg('action')
		local alias = req:get_arg('alias')
		if key then
			local db = app.model:get('keys')
			db:init()

			local r, err
			if action == 'add' then
				r, err = db:add(lwf.ctx.user.username, key, alias)
				print(r, err)
			elseif action == 'delete' then
				r, err = db:delete(lwf.ctx.user.username, key)
			elseif action == 'alias' then
				r, err = db:set_alias(lwf.ctx.user.username, key, alias)
			else
				err = 'Action is not known to us'
			end
			if not r then
				res:write(err)
				return lwf.set_status(403)
			end
		else
			res:write('No key sepecified')
			return lwf.set_status(403)
		end
		res:write('DONE')
	end
}
