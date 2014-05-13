return {
	get = function(req, res)
		req:read_body()
		local path = req:get_arg('path')
		if not path then
			lwf.exit(404)
		end

		local db = app.model:get('db')
		db:init()
		local username, appname = path:match('^([^/]+)/(.+)$')
		local appinfo = db:get_app(username, appname)
		db:close()

		local info = {
			author = username,
			name = appname,
			['type'] = appinfo.apptype or 'app',
			desc = appinfo.desc,
		}
		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'

		local callback = req:get_arg('callback')
		if not callback then
			res:write(cjson.encode(info))
		else
			res:write(callback)
			res:write('(')
			res:write(cjson.encode(info))
			res:write(')')
		end
	end
}
