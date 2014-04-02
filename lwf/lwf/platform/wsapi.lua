local _M = {}
local request = require 'lwf.platform.wsapi.request'
local response = require 'lwf.platform.wsapi.response'
local httpd = require 'lwf.platform.wsapi.httpd'

local function say(lwf)
	local lwf = lwf
	return function(str)
		lwf.ctx._res:write(str)
	end
end

local function exit(lwf)
	local lwf = lwf
	return function(status)
		lwf.ctx._res.status = status
		lwf.ctx._aborted = true
		lwf.ctx._res:write(httpd.err[status])
		lwf.ctx._res._eof = true
	end
end


local function set_status(lwf)
	local lwf = lwf
	return function(status)
		lwf.ctx._res.status = status
	end
end

local function create_lwf()
	local lwf = {
		var = {
			LWF_HOME = os.getenv('LWF_HOME'),
			LWF_APP_NAME = os.getenv('LWF_APP_NAME'),
			LWF_APP_PATH = os.getenv('LWF_APP_PATH'),
		},
		ctx = {
			_res = nil
		},
	}
	lwf.say = say(lwf)
	lwf.exit = exit(lwf)
	lwf.set_status = set_status(lwf)
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
