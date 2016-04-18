
return function (lwf, app, cfg)
	assert(cfg)
	local auth = nil
	if type(cfg) == 'string' then
		auth = require('lwf.auth.'..cfg)
	elseif type(cfg) == 'table' then
		local an = cfg.name
		auth = require('lwf.auth.'..an)
	elseif type(cfg) == 'function' then
		auth = { new = cfg }
	else
		assert('Incorrect configuration for auth')
	end
	assert(auth)
	local authenticate = auth.authenticate
	auth.authenticate = function(self, username, password, ...)
		local r, err = authenticate(self, username, password, ...)
		local identity, err = self:get_identity(username)
		if not identity then
			return nil, err
		end

		local session = lwf.ctx.session
		session:set('username', username)
		session:set('identity', identity)
		--logger:info(username, ', ', identity)

		local user = app:__create_user(username)
		lwf.ctx.user = user
		return true
	end

	return {
		create = function()
			local auth = auth.new(lwf, app, cfg)
			if auth.startup then
				self._auth:startup()
			end
			return auth
		end,
		close = function(auth)
			if auth.teardown then
				self._auth:teardown()
			end
		end
	}
end
