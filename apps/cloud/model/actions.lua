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
	con:select(7)
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

	local r, err = self.con:smembers('actions.set.'..key)
	if not r then
		return nil, err or 'No value in db'
	end
	if r == ngx.null then
		return {}
	end
	local list = {}
	for _, v in ipairs(r) do
		local r, err = self.con:get('action.info.'..v)
		if r and r ~= ngx.null then
			list[#list + 1] = cjson.decode(r)
		else
			self.con:srem(v)
		end
	end

	return list
end

function class:add(key, action)
	if not self.con then
		return nil, 'Db not initialized'
	end
	assert(action.name)
	action.id = action.id or os.time()
	action.status = action.status or 'WAITING'

	local r, err = self.con:sadd('actions.set.'..key, action.id)
	if not r then
		return nil, err
	end
	local r, err = self.con:set('action.info.'..action.id, cjson.encode(action))
	return r, err
end

function class:finish(key, id, result, err)
	if not self.con then
		return nil, 'Db not initialized'
	end
	assert(key and id)
	self.con:sadd('actions.set.done.'..key, id)
	r, err = self.con:srem('actions.set.'..key, id)
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
	local r, err = self.con:get('action.info.'..id)
	if not r or r == ngx.null then
		return nil, err or 'Not exits'
	end
	local action = cjson.decode(r)
	action.status = status
	action.err = err
	local r, err = self.con:set('action.info.'..id, cjson.encode(action))
end

return _M
