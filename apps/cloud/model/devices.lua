local mysql = require 'resty.mysql'
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

	local con = mysql:new()
	con:set_timeout(500)
	local ccfg = {
		database='kooweb',
		host='127.0.0.1',
		port=3306,
		user='root',
		password='19840310'
	}
	local ok, err = con:connect(ccfg)
	if not ok then
		print(err)
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

function class:add(key, device_obj)
	if not self.con then
		return nil, 'Database connection is not initialized'
	end
	local device = cjson.encode(device_obj)

	--- TODO: FIX
	local r, err = self.con:sadd('devices.set.'..key, device_obj.path)
	if not r then
		return nil, err
	end

	r, err = self.con:set('devices.info.'..key..'.'..device_obj.path, device)
	return r, err
end

function class:list(key)
	local r, err = self.con:smembers('devices.set.'..key)
	if not r then
		return nil, err
	end
	if r == ngx.null then
		r = {}
	end
	return r
end

function class:get(key, device_path)
	local device, err = self.con:get('devices.info.'..key..'.'..device_path)
	if not device then
		return nil, err
	end
	if device == ngx.null then
		return nil, 'No exits'
	end

	return cjson.decode(device)
end

function class:clean(key)
	local l, err = self:list(key)
	if not l then 
		return err
	end
	for _, path in pairs(l) do
		self.con:del('devices.info.'..key..'.'..path)
	end
	self.con:del('devices.set.'..key)
end

return _M
