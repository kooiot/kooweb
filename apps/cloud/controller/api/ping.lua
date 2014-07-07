return {
	post = function(req, res)
		local key = req.headers.user_auth_key
		if not key then
			res:write('No user auth key')
			res.status = 403
			return
		end


		local db = app.model:get('devices')
		db:init()

		db:online(key)
	end
}
