local function doi(req, res)
	if lwf.ctx.user then
		lwf.ctx.user:logout()
	end
	res:ltp('login.html')
end

return {
	post = doi,
	get = doi,
}
