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

		res:ltp('app.html', {app=app, lwf=lwf, applist=applist, myapps=myapps})
	end
}
