--- List the applications installed in devcies
--
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
	local r, err = self.con:get('apps.'..key)
	if not r or r == ngx.null then
		return nil, err or 'No value in db'
	end

	return cjson.decode(r)
end

function class:set(key, list)
	if not self.con then
		return nil, 'Db not initailized'
	end

	local info = {
		ts = os.time(),
		list = list,
	}
	self.con:set('apps.'..key, cjson.encode(info))
end

return _M
