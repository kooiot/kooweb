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
	local ok, err = con:connect('127.0.0.1', 6379)
	if not ok then
		print(err)
		logger:error(err)
		return nil
	end
	con:select(9)
	self.con = con
	return true
end

function class:close()
	self.con:close()
	self.con = nil
end

function class:get_user(key)
	local con = self.con
	if con then
		local r, err = con:get('userkey.key.'..key)
		if r == ngx.null then
			return nil, 'User authkey is no exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:list(username)
	local con = self.con
	if con then
		local r, err = con:smembers('userkey.user.'..username)
		if r == ngx.null then
			return nil, 'No exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:add(username, key, alias)
	local con = self.con
	if con then
		local uname = self:get_user(key)
		if uname then
			if uname ~= username then
				return nil, 'The auth key has been used by other user'..uname
			else
				return nil, 'The keys exists!!!'
			end
		end

		local r, err = con:set('userkey.key.'..key, username)
		if not r then
			return nil, err
		end
		if alias then
			local r, err = con:set('userkey.alias.'..key, alias)
			if not r then 
				return nil, err
			end
		end
		r, err = con:sadd('userkey.user.'..username, key)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

function class:set_alias(username, key, alias)
	local r, err = self.con:set('userkey.alias.'..key, alias)
	if not r then 
		return nil, err
	end
	return true
end

function class:alias(username, key)
	local r, err = self.con:get('userkey.alias.'..key, alias)
	if not r or r == ngx.null then 
		return nil, err or 'Not exists'
	end
	return r
end

function class:delete(username, key)
	local con = self.con
	if con then
		local uname = self:get_user(key)
		if not uname or uname ~= username then
			return nil, 'The auth key is not belongs to '..uname
		end

		local r, err = con:del('userkey.key.'..key, username)
		if not r then
			return nil, err
		end
		r, err = con:srem('userkey.user.'..username, key)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

return _M
