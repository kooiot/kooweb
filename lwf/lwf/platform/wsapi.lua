local _M = {}
local request = require 'lwf.platform.wsapi.request'
local response = require 'lwf.platform.wsapi.response'

local function content_write(content)
	content = content or {}
	return function(str)
		table.insert(content, str)
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
			content = {},
		},
		status = 200, -- the status saved for response
	}
	lwf.say = content_write(lwf.content)

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
