return {
	get = function(req, res)
		local appname = req:get_arg('app')
		if not appname then
			lwf.redirect('/')
		else
			res:ltp('app/detail.html', {app=app, lwf=lwf, name=appname})
		end
	end
}
