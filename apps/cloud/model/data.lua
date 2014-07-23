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
	con:select(8)
	self.con = con
	return true
end

function class:close()
	--print('close................')
	self.con:close()
	self.con = nil
end

function class:list(key, path, len)
	if not self.con then
		return nil, 'Db not initialized'
	end

	local len = len or 512
	len = 0 - len
	local k = 'data.list.'..key..'.'..path

	local r, err = self.con:lrange(k, len, -1)
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

function class:get(key, path)
	if not self.con then
		return nil, 'Db not initialized'
	end
	local k = 'data.list.'..key..'.'..path

	local r, err = self.con:lrange(k, -1, -1)
	if not r or r == ngx.null then
		return nil, err or 'No value in db'
	end
	if #r ~= 1 then
		return nil, 'Unknown'
	end
	return cjson.decode(r[1])
end

function class:add(key, path, list)
	if not self.con then
		return nil, 'Db not initialized'
	end
	local k = 'data.list.'..key..'.'..path

	for _, v in ipairs(list) do
		local count, err = self.con:rpush(k, cjson.encode(v))
		if not count then
			return nil, err
		end
		if count > 100000 then
			self.con:lpop()
		end
	end

	--[[
	local len, err = self.con:llen(k)
	if len > 512 then
		len = len - 512
		for i = 0, len do
			self.con:lpop()
		end
	end
	]]--

	return true
end

return _M
