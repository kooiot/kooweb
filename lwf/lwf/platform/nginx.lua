local _M = {}

function _M.init(lwf)
	ngx.Request = require 'lwf.platform.nginx.request'
	ngx.Response = require 'lwf.platform.nginx.response'
	return ngx
end

return _M
