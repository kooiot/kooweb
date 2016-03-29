local _M = {}
local request = require 'lwf.platform.nginx.request'
local response = require 'lwf.platform.nginx.response'

local function create_lwf()
	return {
		var = {
			LWF_HOME = ngx.var.LWF_HOME,
			LWF_APP_NAME = ngx.var.LWF_APP_NAME,
			LWF_APP_PATH = ngx.var.LWF_APP_PATH,
		},
		ctx = {
			_res = nil,
		},
		say = ngx.say,
		exit = ngx.exit,
	}
end

function _M.init()
	local lwf = create_lwf(ngx)
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
