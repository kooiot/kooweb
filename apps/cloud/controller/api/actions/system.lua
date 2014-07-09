return {
	get = function(req, res)
		req:read_body()

		local key = req.headers.user_auth_key

		if not key then
			res:write('No user auth key')
			lwf.set_status(403)
			return
		end


		local db = app.model:get('actions')
		db:init()
		local list = db:list(key) or {}
		for _, v in ipairs(list) do
			db:set_status(v.id, 'PROCESSING')
		end

		local cjson = require 'cjson'
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
			local action = cjson.decode(json)
			if action.id then
				local actions = app.model:get('actions')
				actions:init()
				actions:finish(key, action.id, action.result, action.err)
			else
				res:write('Action id is not present')
				lwf.set_status(403)
				return
			end

			if action.name == 'list' then
				local db = app.model:get('apps')
				db:init()
				db:set(key, action.list)
			end
			if action.name == 'list_services' then
				local db = app.model:get('services')
				db:init()
				db:set(key, action.list)
			end
			if action.name == 'abort_services' then
			end

		else
			res:write('No Json')
			lwf.set_status(403)
		end
	end
}
