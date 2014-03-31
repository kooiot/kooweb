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
end

function class:set_password(username, password)
end

function class:add_user(username, password, mt)
end

function class:get_metadata(username, key)
end

function class:is_exists(username)
end
