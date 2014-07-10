return {
	post = function(req, res)
		req:read_body()
		local key = req:get_arg('key')
		local path = req:get_arg('path')

		if not key or not path then
			res:write('No key or path specified')
			return lwf.set_status(403)
		end

		print(key, path)

		local command = {}
		command.path = path

		local args = req:get_arg('args')
		if string.len(args) == 0 then
			args = nil
		end
		local cjson = require 'cjson'
		command.args = args and cjson.decode(args)

		local db = app.model:get('commands')
		db:init()

		local r, err = db:add(key, command)
		if r then
			res:write('DONE')
		else
			res:write(err)
		end
	end

}
