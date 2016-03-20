return {
	get = function(req, res)
		local db = app.model:get('db')
		db:init()
		local apps = db:list_all()
		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local callback = req:get_arg('callback')
		local typ = req:get_arg('type')
		local key = req:get_arg('key')
		local limit = req:get_arg('limit') -- not used so far

		if key and string.len(key) ~= 0 then
			key = key:lower()
			local t = {}
			for author, list in pairs(apps) do
				for _, v in pairs(list) do
					if v.name:lower():match(key) or (v.info.desc and v.info.desc:lower():match(key)) then
						t[author] = t[author] or {}
						table.insert(t[author], v)
					end
				end
			end
			apps = t
		end

		if not callback then
			res:write(cjson.encode(apps))
		else
			res:write(callback)
			res:write('(')
			res:write(cjson.encode(apps))
			res:write(')')
		end
	end
}
