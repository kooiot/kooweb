return {
	post = function(req, res)
		req:read_body()
		local cjson = require 'cjson'
		local authkey = req.headers.authkey
		if not authkey then
			res:write('Authkey not founded in http headers')
			return
		end
		local json = req:get_arg('json')
		if not json then
			res:write('JSON Data not found in post')
			return
		end

		local db = app.model:get('db')
		db:init()

		local username, err = db:check_user_key(authkey) 
		if not username then
			res:write(err)
			return
		end

		local cjson = require 'cjson'
		local t = cjson.decode(json)
		assert(t.app_path, 'You need to have app_path in json')
		assert(t.name)
		assert(t.desc)
		assert(t.content)
		t.path = username..'/'..t.name
		local r, err = db:update_tpl(t.app_path, t)

		if r then
			res.headers['Content-Type'] = 'application/json; charset=utf-8'
			res:write(cjson.encode(t))
		else
			res:write(err)
		end
	end
}
