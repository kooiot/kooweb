return {
	get = function(req, res, appname)
		local appname = appname or req:get_arg('app')
		if not appname then
			lwf.redirect('/')
		else
			local db = app.model:get('db')
			db:init()
			local username, appname = appname:match('^([^/]+)/(.+)$')
			if not username or not appname then
				lwf.redirect('/')
			else
				local info = db:get_app(username, appname)
				info.username = username
				res:ltp('app/detail.html', {app=app, lwf=lwf, info=info})
			end
		end
	end
}
