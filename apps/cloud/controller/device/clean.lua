return {
	post = function(req, res)
		req:read_body()
		local key = req:get_arg('key')

		local db = app.model:get('devices')
		db:init()

		db:clean(key)
	end
}
