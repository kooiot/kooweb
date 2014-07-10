return {
	post = function(req, res)
		req:read_body()
		local key = req:get_arg('key')
		local action = req:get_arg('action')

		if not key or not action then
			res:write('No key or action specified')
			return lwf.set_status(403)
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
		elseif action == 'upgrade' then
			info.insname = req:get_arg('insname')
			info.version = req:get_arg('version')
		elseif action =='app_start' then
			info.insname = req:get_arg('insname')
			info.debug = req:get_arg('debug')
		elseif action =='app_stop' then
			info.insname = req:get_arg('insname')
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
