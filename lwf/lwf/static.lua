
local class = {}
local _M = {}

function _M.new(app, path)
	local o = {
		app = app,
		path = path or app.app_path..'/static/',
	}
	return setmetatable(o, {__index=class})
end

function class:_handler(request, response, filename)
	if filename then
		filename = self.path..filename
		return response:sendfile(filename)
	end
	response:finish()
	response:do_defers()
	response:do_last_func()
end

return _M

