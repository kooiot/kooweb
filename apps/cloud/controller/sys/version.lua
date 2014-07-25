return {
	get = function(req, res)
		local db = app.model:get('sys')
		db:init()
		local version = db:latest() or 0
		db:close()
		res:write(tostring(version))
	end
}
