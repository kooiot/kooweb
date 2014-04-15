return {
	get = function(req, res)
		local applist = {}
		local user = lwf.ctx.user
		if user then
			local db = app.model:get('db')
			if db:init() then
				applist = db:list_apps(user.username)
			end
		end
		res:ltp('index.html', {app=app, lwf=lwf, applist=applist})
	end
}
