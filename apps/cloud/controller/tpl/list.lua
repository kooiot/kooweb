return {
	get = function(req, res)
		local cjson = require 'cjson'
		local path = req:get_arg('path')

		local db = app.model:get('db')
		db:init()

		local list = db:list_tpl(path)
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		res:write(cjson.encode(list))
	end
}
