return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			return res:redirect('/')
		end
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end

		local apps = app.model:get('apps')
		apps:init()

		local alist, err = apps:list(key)
		alist = alist or {}
		alist.list = alist.list or {}
		alist.ts = os.date('%c', alist.ts or 0)

		local services = app.model:get('services')
		services:init()

		local slist, err = services:list(key)
		slist = slist or {}
		slist.list = slist.list or {}
		slist.ts = os.date('%c', slist.ts or 0)

		local logs = app.model:get('logs')
		logs:init()
		local loglist, err = logs:list(key)
		loglist = loglist or {}

		res:ltp('device/remote.html', {lwf=lwf, app=app, apps=alist, services=slist, logs=loglist, key=key})
	end,
}
