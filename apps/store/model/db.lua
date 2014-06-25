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
	self.con = con
	return true
end

function class:close()
	self.con:close()
	self.con = nil
end

function class:list_apps(username)
	assert(username)
	local con = self.con
	if con then
		local num, err = con:llen('applist.'..username)
		if num and num ~= ngx.null then
			local r, err = con:lrange('applist.'..username, 0, num)
			if r and r ~= ngx.null then
				local apps = {}
				for k, v in pairs(r) do
					local appinfo, err = self:get_app(username, v)
					if appinfo then
						apps[k] = {name=v, info=appinfo}
					end
				end
				return apps
			else
				print(err)
			end
		end
	end
end

function class:list_all()
	local apps = {}
	local con = self.con
	if con then
		local users, err = con:keys('applist.*')
		for _, user in pairs(users) do
			local user = user:match('^applist%.(.+)$')
			if user then
				print(user)
				apps[user] = self:list_apps(user)
			end
		end
	end
	return apps
end

function class:get_app(username, appname)
	assert(appname)
	local con = self.con
	if con then
		local info, err = con:get('appinfo.'..username..'.'..appname)
		if info and info ~= ngx.null then
			return cjson.decode(info)
		end
	end
end

function class:create_app(username, appname, info)
	local con = self.con
	if con then
		con:lpush('applist.'..username, appname)
		return con:set('appinfo.'..username..'.'..appname, cjson.encode(info))
	end
end

function class:update_app(username, appname, info)
	local con = self.con
	if con then
		return con:set('appinfo.'..username..'.'..appname, cjson.encode(info))
	end
end

function class:check_user_key(key)
	local con = self.con
	if con then
		local r, err = con:get('userkey.key.'..key)
		if r == ngx.null then
			return nil, 'No exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:get_user_key(username)
	local con = self.con
	if con then
		local r, err = con:get('userkey.user.'..username)
		if r == ngx.null then
			return nil, 'No exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:set_user_key(username, key)
	local con = self.con
	if con then
		local uname = self:check_user_key(key)
		if uname and uname ~= username then
			return nil, 'The auth key has been used by other user'..uname
		end

		local r, err = con:set('userkey.key.'..key, username)
		if not r then
			return nil, err
		end
		r, err = con:set('userkey.user.'..username, key)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

return _M
