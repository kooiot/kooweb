
return {
	get = function(req, res)
		res:ltp('login.html')
	end,
	post = function(req, res)
		req:read_body()
		logger:debug(req:get_post_arg('username'))
		logger:debug(req:get_post_arg('password'))
		res:redirect('/')
	end
}
