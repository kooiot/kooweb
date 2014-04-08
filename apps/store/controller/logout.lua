return {
	post = function(req, res)
		lwf.ctx.session:clear()
		res:ltp('login.html')
	end
}
