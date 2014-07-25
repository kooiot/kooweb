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
	self.con = con
	return true
end

function class:close()
	--print('close................')
	self.con:close()
	self.con = nil
end

function class:list()
	if not self.con then
		return nil, 'Db not initialized'
	end

	local r, err = self.con:smembers('coresys.version.set')
	if not r then
		return nil, err or 'No value in db'
	end
	if r == ngx.null then
		return {}
	end

	return r
end

function class:latest()
	if not self.con then
		return nil, 'Db not initialized'
	end

	local r, err = self:list()
	if not r then
		return nil, err
	end

	table.sort(r)
	return r[#r]
end

function class:push(version)
	if not self.con then
		return nil, 'Db not initialized'
	end
	return self.con:sadd('coresys.version.set', version)
end

return _M
