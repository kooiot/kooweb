return {
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
			local device = cjson.decode(json)

			local db = app.model:get('devices')
			db:init()
			local r, err = db:add(key, device)
			if not r then
				res:write(err)
				lwf.set_status(403)
			end
		else
			res:write('No Json')
			lwf.set_status(403)
		end
	end
}
