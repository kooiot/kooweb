return {
	get = function(req, res)
		local cjson = require 'cjson'
		local list = {afad={'dfadfa','dafadfa'}}
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		res:write(cjson.encode(list))
	end
}
