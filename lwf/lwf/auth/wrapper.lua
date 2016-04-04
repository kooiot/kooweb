
local unpack_table = table.unpack or unpack

local function build_func(func)
	local func = func
	return function(self, ...) 
		self._auth:attach()
		return func(self._auth, ...), self._auth:detach()
	end
end

local function new(cfg, lwf, app)
	assert(cfg)
	local auth = nil
	if type(cfg) == 'string' then
		auth = require('lwf.auth.'..cfg).new(lwf, app)
	elseif type(cfg) == 'function' then
		auth = cfg(lwf, app)
	else
		assert('Incorrect configuration for auth')
	end
	assert(auth)

	local obj = {
		_auth = auth,
	}

	obj.authenticate = build_func(auth.authenticate)
	obj.identity = build_func(auth.identity)
	obj.get_identity = build_func(auth.get_identity)
	obj.clear_identity = build_func(auth.clear_identity)
	obj.set_password = build_func(auth.set_password)
	obj.add_user = build_func(auth.add_user)
	obj.get_metadata = build_func(auth.get_metadata)
	obj.has = build_func(auth.has)

	return obj
end

return {
	new = new
}
