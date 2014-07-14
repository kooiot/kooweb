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
		local line_table = {}
		local string_table = {}
		local has_line_data = false
		for _, v in pairs(list) do
			if type(v.value) == 'number' then
				local mc = nil
				if not v.quality then
					mc = "red"
				end
				has_line_data = true
				line_table[#line_table + 1] = {x=v.timestamp, y=v.value, markerColor=mc}
			else
				string_table[#string_table + 1] = v
			end
		end
		local cjson = require 'cjson'
		local line_data = cjson.encode(line_table)

		res:ltp('device/data.html', {lwf=lwf,app=app, data=string_table, line_data=line_data, has_line_data=has_line_data, key=key, path=path})
	end,
}
