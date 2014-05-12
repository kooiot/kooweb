return {
	get = function(req, res)
		if not lwf.ctx.user then
			res:redirect('/user/login')
		end
		res:ltp('user/profile.html')
	end,
	post = function(req, res)
	end,
}
