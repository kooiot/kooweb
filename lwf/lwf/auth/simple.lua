-- Authentification module
--

local md5 = require 'md5'

local _M = {}
local class = {}
local salt = "SimpleAuth"

local function load_auth_file(path)
	local keys = {}
	keys.admin = 'admin'

	if not path then
		return keys
	end

	local file, err = io.open(path)
	if file then
		local c = file:read('*a')
		for k, v in string.gmatch(c, "(%w+)=(%w+)") do
			keys[k] = v
		end
	end

	return keys
end

local function save_auth_file(path, keys)
	if not path then
		return nil, "file not configured"
	end

	local file, err = io.open(path, 'w+')
	if not file then
		return nil, err
	end

	for k, v in pairs(keys) do
		file:write(k)
		file:write('=')
		file:write(v)
	end

	file:close()

	return true
end

_M.new = function(lwf, app)
	local obj = {
		lwf = lwf,
		app = app,
		path = app.config.auth_file
	}
	obj.keys = load_auth_file(obj.path)

	return setmetatable(obj, {__index=class})
end

function class:authenticate(username, password)
	local md5passwd = md5.sumhexa(username..salt)
	if self.keys[username] and self.keys[username] == md5passwd then
		return true
	end
	return false, 'Incorrect username or password'
end

function class:identity(username, identity)
	local dbidentity = md5.sumhexa(username..salt)
	return dbidentity == identity
end

function class:get_identity(username)
	return  md5.sumhexa(username..salt)
end

function class:clear_identity(username)
	return true
end

function class:set_password(username, password)
	self.keys[username] = md5.sumhexa(password..salt)
	save_auth_file(self.path, self.keys)
end

function class:add_user(username, password, mt)
	self.keys[username] = md5.sumhexa(password..salt)
	save_auth_file(self.path, self.keys)
end

function class:get_metadata(username, key)
	return nil, 'Meta data is not support by simple auth module'
end

function class:has(username)
	if self.keys[username] then
		return true
	else
		return false
	end
end

return _M
