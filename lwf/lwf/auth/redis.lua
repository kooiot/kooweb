-- Authentification module (by using nosql:redis)
--

local logger = require 'lwf.logger'
local redis = require 'resty.redis'
local cjson = require 'cjson'
local md5 = require 'md5'

local _M = {}
local class = {}

_M.new = function(lwf, app)
	local red = redis:new()
	red:set_timeout(500)
	local ok, err = red:connect('127.0.0.1', 6379)
	if not ok then
		logger:error(err)
	end
	local obj = {
		lwf = lwf,
		app = app,
		red = red,
	}

	return setmetatable(obj, {__index=class})
end

function class:authenticate(username, password)
	local pw, err = self.red:get('user.'..username) 
	if pw and pw == password then
		return true
	end
	--logger:debug('authenticate: '..username..' Input:'..password..' DB:'..(tostring(pw) or 'nil')..' Error:'..(err or ''))
	if not pw or pw == ngx.null then
		if username == 'admin' and password == 'admin' then
			return true
		end
	end
	return false, 'Incorrect username or password'
end

function class:identity(username, identity)
	local dbidentity = self.red:get('user_identity.'..username)
	if not dbidentity or dbidentity ~= ngx.null then
		local ridentity = md5.sumhexa(username..'TODODO')
		logger:debug('dbidentity '..dbidentity..' ridentity:'..ridentity)
		return dbidentity == ridentity
	else
		logger:debug('identity failure ', username, ' ', identity)
		return false
	end
end

function class:get_identity(username)
	local identity = self.red:get('user_identity.'..username)
	if not identity or identity == ngx.null then
		identity = md5.sumhexa(username..os.date())
		self.red:set('user_identity.'..username, identity)
		--logger:debug('Creates identity:'..identity..' for user:'..username)
	end
	return identity
end

function class:clear_identity(username)
	self.red:del('user_identity.'..username)
	return true
end

function class:set_password(username, password)
	local r, err = self.red:set('user.'..username, password)
	return r, err
end

function class:add_user(username, password, mt)
	local r, err = self.red:set('user.'..username, password) 
	if r then
		r, err = self.red:set('user_mt.'..username, cjson.encode(mt))
		return r, err
	end
	return r, err
end

function class:get_metadata(username, key)
	local json, err = self.red:get('user_mt.'..username)
	if json then
		return cjson.decode(json)
	end
	return nil, err
end

function class:has(username)
	local r, err = self.red:get('user.'..username)
	return r and r ~= ngx.null
end

return _M
