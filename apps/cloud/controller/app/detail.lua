return {
	get = function(req, res, app_path)
		local app_path = app_path or req:get_arg('app')
		if not app_path then
			lwf.redirect('/')
		else
			local db = app.model:get('db')
			db:init()
			local username, appname = app_path:match('^([^/]+)/(.+)$')
			if not username or not appname then
				lwf.redirect('/')
			else
				local info = db:get_app(username, appname)
				info.username = username

				--- Escape the string for avoid attach by input
				local lwfutil = require 'lwf.util'
				info.comments = lwfutil.escape(info.comments)
				info.desc = lwfutil.escape(info.desc)

				local user = lwf.ctx.user
				local applist = {}
				if user then
					applist = db:list_apps(user.username)
				end
				local tplist = db:list_tpl(app_path)
				res:ltp('app/detail.html', {app=app, lwf=lwf, info=info, applist=applist, tplist=tplist})
			end
		end
	end
}
