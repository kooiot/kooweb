local _M = {}
local skynet = require 'skynet'
local request = require 'lwf.platform.skynet.request'
local response = require 'lwf.platform.skynet.response'
local filehandler = require 'lwf.platform.skynet.filehandler'
local httpd = require 'lwf.platform.skynet.httpd'

local getenv = skynet.getenv

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
	return {
		var = {
			LWF_HOME = getenv('LWF_HOME'),
			LWF_APP_NAME = getenv('LWF_APP_NAME'),
			LWF_APP_PATH = getenv('LWF_APP_PATH'),
		},
		ctx = {
			_res = nil,
		},
	}
end

function _M.init()
	local lwf = create_lwf()
	lwf.create_request = function()
		return request.new(lwf)
	end
	lwf.create_response = function()
		return response.new(lwf)
	end
	lwf.say = say(lwf)
	lwf.exit = exit(lwf)
	lwf.set_status = set_status(lwf)
	lwf.static_handler = filehandler
	return lwf
end

return _M
