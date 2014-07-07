return {
	get = function(req, res, key)
		local key = key or req:get_arg('key')
		if not key then
			return res:redirect('/')
		end
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end
		res:write(key)
	end
}
