local redis = require 'resty.redis'
local logger = require 'lwf.logger'
local cjson = require 'cjson'

local _M = {}
local class = {}

_M.new = function(m)
	local obj = {
		lwf = m.lwf,
		app = m.app,
		con = con
	}

	return setmetatable(obj, {__index=class})	
end

function class:init()
	if self.con then 
		return true
	end

	local con = redis:new()
	con:set_timeout(500)
--	print(con: get_reused_times())
	local ok, err = con:connect('127.0.0.1', 6379)
	if not ok then
		print(err)
		logger:error(err)
		return nil, err
	end
	con:select(9)
	self.con = con
	return true
end

function class:close()
	--print('close................')
	self.con:close()
	self.con = nil
end

function class:online(key, timeout)
	local timeout = timeout or 30

	local con = self.con
	if con then
		local r, err = con:setex('devices.online.'..key, timeout, 'true')
		if not r then
			return nil, err
		end
		return true
	end
	return nil, 'Database connection is not initialized'
end

function class:is_online(key)
	if not self.con then
		return nil, 'Database connection is not initialized'
	end

	local r, err = self.con:get('devices.online.'..key)
	if not r then
		return nil, err
	end
	return r == 'true'
end

function class:list_online()
	if not self.con then
		return nil, 'Database connection is not initialized'
	end
	local r, err = self.con:keys('devices.online.*')
	if not r then
		return nil, err
	end
	local list = {}
	for _, v in pairs(r) do
		local key = v:match('^devices%.online%.(.+)$')
		list[#list + 1] = key
	end
	return list
end

return _M
