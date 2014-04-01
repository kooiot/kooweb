local _M = {}
local request = require 'lwf.platform.wsapi.request'
local response = require 'lwf.platform.wsapi.response'
local wsapi_response = require 'wsapi.response'

local function create_lwf()
	local _res = wsapi_response.new()
	local lwf = {
		var = {
			LWF_HOME = os.getenv('LWF_HOME'),
			LWF_APP_NAME = os.getenv('LWF_APP_NAME'),
			LWF_APP_PATH = os.getenv('LWF_APP_PATH'),
		},
		ctx = {
			_res = _res
		},
	}
	lwf.say = function(str) lwf.ctx._res:write(str) end
	lwf.exit = function(status)
		lwf.ctx._res.status = status
		lwf.ctx._aborted = true
		lwf.ctx.response._eof = true
	end
	lwf.set_status = function(status)
		lwf.ctx._res.status = status
	end

	return lwf
end

function _M.init(lwf)
	lwf = create_lwf()
	lwf.create_request = function()
		return request.new(lwf)
	end
	lwf.create_response = function()
		return response.new(lwf)
	end
	return lwf
end

return _M
