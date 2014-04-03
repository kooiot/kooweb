local function get(req, resp)
	resp:ltp('apps/index.html')
end

return {
	get = get
}
