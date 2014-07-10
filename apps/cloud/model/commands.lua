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
	con:select(12)
	self.con = con
	return true
end

function class:close()
	--print('close................')
	self.con:close()
	self.con = nil
end

local function gen_id()
	local uuid = require 'lwf.util.uuid'
	return uuid()
end

function class:list(key)
	if not self.con then
		return nil, 'Db not initialized'
	end

	local r, err = self.con:smembers('commands.set.'..key)
	if not r then
		return nil, err or 'No value in db'
	end
	if r == ngx.null then
		return {}
	end
	local list = {}
	for _, v in ipairs(r) do
		local r, err = self.con:get('command.info.'..v)
		if r and r ~= ngx.null then
			list[#list + 1] = cjson.decode(r)
		else
			self.con:srem(v)
		end
	end

	return list
end

function class:add(key, command)
	if not self.con then
		return nil, 'Db not initialized'
	end
	assert(command.path)
	command.id = command.id or gen_id()
	command.status = command.status or 'WAITING'

	local r, err = self.con:sadd('commands.set.'..key, command.id)
	if not r then
		return nil, err
	end
	local r, err = self.con:set('command.info.'..command.id, cjson.encode(command))
	return r, err
end

function class:finish(key, id, result, err)
	if not self.con then
		return nil, 'Db not initialized'
	end
	assert(key and id)
	self.con:sadd('commands.set.done.'..key, id)
	r, err = self.con:srem('commands.set.'..key, id)
	if result then
		self:set_status(id, 'DONE')
	else
		self:set_status(id, 'ERROR', err)
	end
end

function class:set_status(id, status, err)
	if not self.con then
		return nil, 'Db not initialized'
	end
	local r, err = self.con:get('command.info.'..id)
	if not r or r == ngx.null then
		return nil, err or 'Not exits'
	end
	local command = cjson.decode(r)
	command.status = status
	command.err = err
	local r, err = self.con:set('command.info.'..id, cjson.encode(command))
end

return _M
