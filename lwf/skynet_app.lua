#!/usr/bin/env lua
local setup = require 'setup'
local res = require 'lwf.platform.skynet.res'
local coroutine = require 'skynet.coroutine'

local lwf, content = setup('skynet')

local unpack = table.unpack or unpack

---------
return function(env, resp)
	local ctx = {
		sky_env = env,
	}
	ctx._res  = res.new()
	content(ctx)
	
	local status, headers, body = ctx._res:finish()
	
	local bodyfunc = function()
		local r, s =  coroutine.resume(body)
		return r and s
	end
	resp(status, body, headers)	
end
----------

