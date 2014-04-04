local _M = {}
local request = require 'lwf.platform.nginx.request'
local response = require 'lwf.platform.nginx.response'

function _M.init(lwf)
	lwf = ngx
	lwf.create_request = function()
		return request.new(lwf)
	end
	lwf.create_response = function()
		return response.new(lwf)
	end
	lwf.set_status = function(status)
		lwf.status = status
	end
	return lwf
end

return _M
