function get (requ, resp)
	lwf.ctx.session:set('LWF', 'Welcome')
	local username = lwf.ctx.user and lwf.ctx.user.username or nil
	resp:ltp('index.html', {lwf=lwf, app=app, name = "example", username=username})
end

return {
	get = get
}
