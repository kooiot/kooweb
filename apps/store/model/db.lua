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

return _M
