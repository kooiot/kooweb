return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			res:write('Need Key')
			return lwf.set_status(403)
		end
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		local path = req:get_arg('path')
		if not path then
			res:write('Need Path')
			return lwf.set_status(403)
		end

		local username = lwf.ctx.user.username
		local key_alias = nil
		if username then
			local keys = app.model:get('keys')
			keys:init()
			local r, err = keys:alias(username, key)
			if r then
				key_alias = r
			end
		end


		local path = req:get_arg('path')
		if not path then
			res:write('Need Path')
			return lwf.set_status(403)
		end

		local data = app.model:get('data')
		data:init()

		local list = data:list(key, path, 102400)

		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local cjson = require 'cjson'
		res:write(cjson.encode(list))
	end,
}
