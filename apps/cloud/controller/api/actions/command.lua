return {
	get = function(req, res)
		local key = req.headers.user_auth_key

		if not key then
			res:write('No user auth key')
			lwf.set_status(403)
			return
		end

		local db = app.model:get('commands')
		db:init()
		local list = db:list(key) or {}
		for _, v in ipairs(list) do
			db:set_status(v.id, 'PROCESSING')
		end

		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		--print(cjson.encode(list))
		res:write(cjson.encode(list))
	end,
	post = function(req, res)
		req:read_body()

		local key = req.headers.user_auth_key

		if not key then
			res:write('No user auth key')
			lwf.set_status(403)
			return
		end
		local json = req:get_arg('json')
		if json then
			local cjson = require'cjson'
			local command = cjson.decode(json)
			if command.id then
				local db = app.model:get('commands')
				db:init()
				db:finish(key, command.id, command.result, command.err)
			else
				res:write('Command id is not present')
				lwf.set_status(403)
				return
			end
		else
			res:write('No Json')
			lwf.set_status(403)
		end

	end
}
