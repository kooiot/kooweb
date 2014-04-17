return {
	get = function(req, res)
		local applist = {}
		local apps = {}
		local user = lwf.ctx.user
		if user then
			local db = app.model:get('db')
			if db:init() then
				applist = db:list_apps(user.username)
				apps = db:list_all()
			end
		end
		res:ltp('index.html', {app=app, lwf=lwf, applist=applist, apps=apps})
	end
}
