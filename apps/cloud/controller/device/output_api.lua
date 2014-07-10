return {
	post = function(req, res)
		req:read_body()
		local key = req:get_arg('key')
		local path = req:get_arg('path')
		local value = req:get_arg('value')

		if not key or not path or not value then
			res:write('No key, path or value specified')
			return lwf.set_status(403)
		end

		local output = {}
		output.path = path
		output.value = value

		local db = app.model:get('outputs')
		db:init()

		local r, err = db:add(key, output)
		if r then
			res:write('DONE')
		else
			res:write(err)
		end
	end

}
