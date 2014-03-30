local function get(req, resp)
	resp:ltp('aaa.html', {name = "example"})
end

return {
	get = get
}
