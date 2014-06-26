return {
	get = function(req, res)
		local cjson = require 'cjson'
		local appname = req:get_arg('appname')
		local name = req:get_arg('name')
		local content = {appname=appname, name=name}
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		res:write(cjson.encode(content))
	end
}
