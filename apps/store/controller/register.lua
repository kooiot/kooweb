return {
	get = function(req, res)
		res:ltp('register.html')
	end,
	post = function(req, res)
		res:redirect('/')
	end,
}
