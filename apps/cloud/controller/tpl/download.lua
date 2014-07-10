return {
	get = function(req, res)
		local cjson = require 'cjson'
		local app_path = req:get_arg('app_path')
		local path = req:get_arg('path')

		local db = app.model:get('db')
		db:init()

		local t, err = db:get_tpl(app_path, path)
		local content = t.content

		if content then
			res.headers['Content-Type'] = 'application/json; charset=utf-8'
			res:write(content)
		else
			lwf.exit(403, err)
		end
	end
}
