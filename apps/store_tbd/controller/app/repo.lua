return {
	get = function(req, res)
		local db = app.model:get('db')
		db:init()
		local apps = db:list_all()
		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local callback = req:get_arg('callback')
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
