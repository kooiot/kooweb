return {
	get = function(req, res)
		res:ltp('register.html', {lwf=lwf, app=app})
	end,
	post = function(req, res)
		res:redirect('/')
	end,
}
