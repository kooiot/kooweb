-- Encrypto session module
--
local json = require 'cjson'
local md5 = require 'md5'
local base64 = require 'lwf.util.base64'

local hmac = function(str, salt)
	return base64.encode(md5.sumhexa(salt..str))
end

local encode_session = function(session, salt)
	local s = base64.encode(json.encode(session))
	if salt then
		s = s .. "\n--" .. tostring(hmac(s, salt))
	end
	return s
end

local get_session = function(config, request)
  local cookie = request:get_cookie(config.key)
  if cookie then
	  if config.salt then
		  local real_cookie, sig = cookie:match("^(.*)\n%-%-(.*)$")
		  if not (real_cookie and sig == hmac(real_cookie, config.salt)) then
			  return { }
		  end
		  cookie = real_cookie
	  end
	  --local session, err = json.decode(base64.decode(cookie))
	  local _, session = pcall(function()
		  return json.decode((base64.decode(cookie)))
	  end)

	  return session or { }
  end
  return {}
end

local function new(config)
	local class = {}
	function class:read(request)
		self.session = get_session(config, request)
		return self.session
	end

	function class:write(response)
		if self.session then
			response:set_cookie(config.key, encode_session(self.session, config.salt), 0, '/')
		end
	end

	function class:clear()
		self.session = nil
	end

	function class:set(key, value)
		self.session[key] = value
	end

	function class:get(key)
		return self.session[key]
	end

	function class:del(key)
		self.session[key] = nil
	end

	return setmetatable({session={}}, {__index = class})
end

return {
	new = new,
}

