function get (requ, resp)
	lwf.ctx.session:set('bafdlafdlafa', 'dfdddd')
	resp:ltp('aaa.html', {name = "index"})
end

return {
	get = get
}
