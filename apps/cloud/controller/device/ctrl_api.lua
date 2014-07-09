return {
	post = function(req, res)
		req:read_body()
		local key = req:get_arg('key')
		local action = req:get_arg('action')

		if not key or not action then
			return lwf.exit(404)
		end

		local info = {}
		info.name = action
		if action == 'list' then
		elseif action == 'install' then
			info.app_path = req:get_arg('app_path')
			info.insname = req:get_arg('insname')
		elseif action == 'uninstall' then
			info.insname = req:get_arg('insname')
		elseif action == 'logs' then
			info.enable = (req:get_arg('enable') == 'true')
		end

		local actions = app.model:get('actions')
		actions:init()

		local r, err = actions:add(key, info)
		if r then
			res:write('DONE')
		else
			res:write(err)
		end
	end

}
