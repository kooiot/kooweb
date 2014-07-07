return {
	get = function(req, res)
		local db = app.model:get('devices')
		db:init()
		local list, err = db:list_online()
		if not list then
			res:write(err)
		else
			local l = {}
			for _, v in ipairs(list) do
				local devlist, err = db:list('admin', v)
				devlist = devlist or {}
				l[v] = devlist
			end
			local cjson = require 'cjson'
			res:write(cjson.encode(l))
		end
	end
}
