return {
	get = function(req, res)
		local key = req:get_arg('key')
		if not key then
			res:write('Need Key')
			return lwf.set_status(403)
		end
		local path = req:get_arg('path')
		if not path then
			res:write('Need Key')
			return lwf.set_status(403)
		end

		--local data = app.model:get('data')
		local data = app.model:get('influx')
		data:init()

		local list = data:list(key, path)

		res.headers['Content-Type'] = 'application/json; charset=utf-8'
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
		--	print(json)
			local cjson = require'cjson'
			local list = cjson.decode(json)
	
			--local data = app.model:get('data')
			local data = app.model:get('influx')
			data:init()

			for _, v in ipairs(list) do
				local values = {}
				for _, val in ipairs(v.values) do
					values[#values + 1] = {timestamp = val.timestamp, value=val.value, quality=val.quality}
				end
				local r, err = data:add(key, v.path, values)
				if not r then
					res:write(err)
					lwf.set_status(403)
				end
			end
		else
			res:write('No Json')
			lwf.set_status(403)
		end
	end,
}
