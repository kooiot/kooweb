return {
	get = function(req, res)
		if not lwf.ctx.user then
			res:redirect('login')
		else
			res:ltp('about.html')
		end
	end
}
