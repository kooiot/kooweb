return {
	get = function(req, res)
		local myapps = {}
		local applist = {}
		local user = lwf.ctx.user
		local db = app.model:get('db')
		if db:init() then
			if user then
				myapps = db:list_apps(user.username)
			end
			applist = db:list_all()
		end

		local devlist = {}

		if user then
			local db = app.model:get('devices')
			db:init()
			local keys = app.model:get('keys')
			keys:init()

			local list, err = keys:list(user.username)
			if list then
				for _, v in ipairs(list) do
					local l, err = db:is_online(v)
					--print('is_online', l, err, v) -- be careful about space in your device key
					local alias = keys:alias(user.username, v)
					if l then
						devlist[#devlist + 1] = {key=v, alias=alias, online=true}
					else
						devlist[#devlist + 1] = {key=v, alias=alias, online=false}
					end
				end
			end
		end

		res:ltp('index.html', {app=app, lwf=lwf, devlist=devlist, applist=applist, myapps=myapps})
	end
}
