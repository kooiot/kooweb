local function get(req, resp)
	lwf.ctx.session:set('bafdlafdlafa', 'dfdddd')
	resp:ltp('aaa.html', {name = "example"})
end

return {
	get = get
}

