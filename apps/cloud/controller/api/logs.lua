return {
	get = function(req, res)
		local key = req:get_arg('key')
		if not key then
			res:write('Need Key')
			return
		end
		local logs = app.model:get('logs')
		logs:init()
		local list, err = logs:list(key)
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
			local list = cjson.decode(json)
	
			local logs = app.model:get('logs')
			logs:init()
			local r, err = logs:add(key, list)
			if not r then
				res:write(err)
				lwf.set_status(403)
			end
		else
			res:write('No Json')
			lwf.set_status(403)
		end
	end,
}
