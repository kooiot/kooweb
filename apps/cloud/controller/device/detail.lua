return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			return res:redirect('/')
		end
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		local devices = app.model:get('devices')
		devices:init()
		local list, err = devices:list(key)

		local devlist = {}

		local db = app.model:get('data')
		db:init()

		for _, name in ipairs(list) do
			local devobj, err = devices:get(key, name)
			devlist[name] = devobj

			local inputs = devobj.inputs
			for k, v in pairs(inputs) do
				local l, err = db:get(key, v.path)
				if l then
					v.value = l.value
				end
			end
		end

		res:ltp('device/detail.html', {lwf=lwf, app=app, devlist=devlist, key=key})
	end
}