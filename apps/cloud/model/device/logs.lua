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
		--print(err)
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

function class:list(key)
	if not self.con then
		return nil, 'Db not initialized'
	end

	local len, err = self.con:llen('logs.list.'..key)
	if not len or len == 0 then
		return {}
	end

	local r, err = self.con:lrange('logs.list.'..key, 0, len)
	if not r then
		return nil, err or 'No value in db'
	end
	if r == ngx.null then
		return {}
	end

	local list = {}
	for i, v in ipairs(r) do
		list[i] = cjson.decode(v)
	end

	return list
end

function class:add(key, list)
	if not self.con then
		return nil, 'Db not initialized'
	end

	local k = 'logs.list.'..key
	for _, v in ipairs(list) do
		local r, err = self.con:rpush(k, cjson.encode(v))
		if not r then
			return nil, err
		end
	end

	local len, err = self.con:llen(k)
	if len > 512 then
		len = len - 512
		for i = 1, len do
			self.con:lpop(k)
		end
	end

	return true
end

return _M
