return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			res:write('Need Key')
			return lwf.set_status(403)
		end
		local path = req:get_arg('path')
		if not path then
			res:write('Need Key')
			return lwf.set_status(403)
		end

		local data = app.model:get('data')
		data:init()

		local list = data:list(key, path)

		--[[
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local cjson = require 'cjson'
		res:write(cjson.encode(list))
		]]--
		res:ltp('device/data.html', {lwf=lwf,app=app, data=list, key=key, path=path})
	end,
}
