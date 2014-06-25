return {
	get = function(req, res)
		req:read_body()
		local key = req:get_arg('userkey')

		local db = app.model:get('db')
		db:init()

		if not db:find_user_key(key) then
			return lwf.exit(404)
		end

		local path = req:get_arg('path')
		if not path then
			return lwf.exit(404)
		end

		local version = req:get_arg('version')
		-- TODO:

		local username, appname = path:match('^([^/]+)/(.+)$')
		local appinfo, err = db:get_app(username, appname)
		if not appinfo then
			res:write(err)
			lwf.exit(403)
			return
		end
		db:close()

		local info = {
			author = username,
			name = appname,
			version = appinfo.version or '0.0.0',
			['type'] = appinfo.apptype or 'app',
			desc = appinfo.desc,
			depends = {appinfo.depends},
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
