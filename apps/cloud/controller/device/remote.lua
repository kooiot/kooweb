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

		local applist = {}
		local db = app.model:get('db')
		if db:init() then
			local apps = db:list_all()
			for k, v in pairs(apps) do
				for k, v in pairs(v) do
					applist[v.info.path] = v.info
				end
			end
		end

		res:ltp('device/remote.html', {lwf=lwf, app=app, apps=alist, services=slist, logs=loglist, app_list=applist, key=key, key_alias=key_alias})
	end,
}
