-- Authentification module
--

local _M = {}
local class = {}

_M.new = function(lwf, app)
	local obj = {
		lwf = lwf,
		app = app
	}

	return setmetatable(obj, {__index=class})
end

function class:authenticate(username, password)
	if username == 'admin' and password == 'admin' then
		return true
	end
	return false, 'Incorrect username or password'
end

function class:identity(username, identity)
	return true
end

function class:get_identity(username)
	return 'simple'
end

function class:set_password(username, password)
end

function class:add_user(username, password, mt)
end

function class:get_metadata(username, key)
end

function class:has(username)
end

return _M
