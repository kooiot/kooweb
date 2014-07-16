return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			return res:redirect('/')
		end
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end
		local username = lwf.ctx.user.username
		local key_alias = nil
		if username then
			local keys = app.model:get('keys')
			keys:init()
			local r, err = keys:alias(username, key)
			if r then
				key_alias = r
			end
		end

		local devices = app.model:get('devices')
		devices:init()
		local list, err = devices:list(key)

		local devlist = {}

		local db = app.model:get('data')
		db:init()

		for _, path in ipairs(list) do
			local devobj, err = devices:get(key, path)
			devlist[path] = devobj

			local inputs = devobj.inputs
			for k, v in pairs(inputs) do
				local l, err = db:get(key, v.path)
				if l then
					v.value = l.value
				end
			end
		end

		res:ltp('device/detail.html', {lwf=lwf, app=app, devlist=devlist, key=key, key_alias=key_alias})
	end
}
