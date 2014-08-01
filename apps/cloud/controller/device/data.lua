local function get_type(app, key, path)
	local devices = app.model:get('devices')
	devices:init()
	local devpath, t, k = path:match('^([^/]+/[^/]+)/([^/]+)/([^/]+)')
	--print(path)
	if not ( devpath and t and k ) then
		return nil, 'Path incorrect'
	end

	--print(devpath, t, k)
	local devobj = devices:get(key, devpath)
	if not devobj then
		return nil, 'Device not found'
	end

	local obj = devobj[t][k]
	if not obj then
		return nil, 'Object not found in devices'
	end

	if obj.props['type'] and obj.props['type'].value then
		return obj.props['type'].value
	end
	return nil, 'Type props not found'
end

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

		local data_type, err = get_type(app, key, path)
		if not data_type then
			data_type = "number"
		end

	--	local data = app.model:get('data')
		local data = app.model:get('influx')
		data:init()

		local list, err = data:list(key, path, 102400)
		if not list then
			res:write(err)
			return
		end

		--[[
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local cjson = require 'cjson'
		res:write(cjson.encode(list))
		]]--
		local line_data = nil
		local has_line_data = false

		if data_type:match("^number") then
			local line_table = {}
			has_line_data = true
			for _, v in ipairs(list) do
				local mc = nil
				if not v.quality then
					mc = "red"
				end
				line_table[#line_table + 1] = {x=v.timestamp, y=tonumber(v.value), markerColor=mc}
			end

			local cjson = require 'cjson'
			line_data = cjson.encode(line_table)
		end

		res:ltp('device/data.html', {lwf=lwf,app=app, data=list, line_data=line_data, has_line_data=has_line_data, key=key, path=path, key_alias=key_alias})
	end,
}
