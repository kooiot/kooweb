
local util = require 'lwf.util'
local router = require 'lwf.router'
local lwfdebug = require 'lwf.debug'
local session = require 'lwf.session'
local model = require 'lwf.model'
local logger = require 'lwf.logger'

local class = {}

local function concat_path(base, path, default)
	local path = path or default
	if path[1] ~= '/' then
		path = base..'/'..path
	end
	return path..'/'
end

local function translate_config(path, c)
	c.templates = concat_path(path, c.templates, 'templates')
	c.controller = concat_path(path, c.controller, 'controller')
	c.model = concat_path(path, c.model, 'model')
	c.router = c.router or 'auto'
	local static = c.static
	if static then
		c.static = concat_path(path, static, 'static')
	end
end

local function translate_session(c)
	c.session.key = c.session.key or 'lwfsession'
	assert(c.session.salt)
end

local function new(lwf, name, path)
	local app = {
		lwf = lwf,
		app_name = name,
		app_path = path,
		io = io,
		assert = assert,
	}

	local app_config = path .. "/config.lua"
	local r, c = util.loadfile(app_config, app)
	assert(r, c)
	assert(c)
	translate_config(path, c)
	if c.session then
		translate_session(c)
	end
	app.config = c
	assert(app.app_name)
	assert(app.app_path)
	assert(app.lwf)


	local obj = setmetatable(app, {__index=class})
	obj:init()

	return obj
end

function class:init()
	self.model = model.new(lwf, self.config.model)

	local has_subapps = self.config.subapps and type(self.config.subapps) == "table"
    
    if has_subapps then
		self.subapps = {}
        for k, t in pairs(self.config.subapps) do
			local r, subapp = pcall(new, self.lwf, k, t.path)
			if r then
				local subapp = new(self.lwf, k, t.path)
				subapp.base_app = self
				table.insert(self.subapps, {name=k, app = subapp})
			else
				print('Loading sub application failed, error:'..subapp)
			end
        end
    end

	-- load the main-app's routing
	local rfile = self.app_path .. "/routing.lua"
	router.setup(self, rfile)

    if self.subapps and #self.subapps ~= 0 then
		-- merge routings
		router.merge_routings(self, self.subapps or {})
	end

    if self.config.debug and self.config.debug.on and lwfdebug then
        debug.sethook(debug.debug_hook, "cr")
    end
	
	local authconfig = self.config.auth
	if authconfig then
		if type(authconfig) == 'string' then
			--logger:info('Created authentication module['..authconfig..']')
			self.auth = require('lwf.auth.'..authconfig).new(self.lwf, self)
		elseif type(authconfig) == 'function' then
			self.auth = authconfig(self.lwf, self)
		else
			assert('Incorrect configuration for auth')
		end
		assert(self.auth)
	end
end

function class:__create_user(username)
	local user = {
		app = self,
		username = username,
		-- TODO: more user meta
		logout = function(self)
			assert(self and self.app)
			self.app.lwf.ctx.session:clear()
			self.app.lwf.ctx.user = nil
			self.app.auth:clear_identity(self.username)
		end
	}
	return user
end

function class:identity()
	local ctx = self.lwf.ctx
	local session = ctx.session
	local username = session:get('username')
	local identity = session:get('identity')
	if username and identity then
		logger:info('Identity '..username..' '..identity)
		local r, err = self.auth:identity(username, identity)
		if r then
			--logger:info('Identity OK '..username..' '..identity)
			-- Create user object
			local user = self:__create_user(username)
			ctx.user = user
		else
			--logger:info('Identity Failure '..username..' '..identity)
			-- Clear session data
			session:clear()
		end
	else
		--[[
		local err = 'Identity lack of '
		if not username then
			err = err..'username'
		end
		if not identity then
			err = err..'identity'
		end
		logger:debug(err)
		]]--
	end
end

function class:authenticate(username, password, ...)
	local auth = self.auth
	if not auth then
		--logger:error('No auth module configured in your config.lua')
		return nil, 'No auth module configured in your config.lua'
	end

	local r, err = self.auth:authenticate(username, password, ...)
	if not r then
		return nil, err
	end
	local identity, err = self.auth:get_identity(username)
	if not identity then
		return nil, err
	end

	local session = self.lwf.ctx.session
	session:set('username', username)
	session:set('identity', identity)
	--logger:info(username, ', ', identity)

	local user = self:__create_user(username)
	self.lwf.ctx.user = user
	return true
end

function class:dispatch()
	local lwf = self.lwf
	local ctx = lwf.ctx
	ctx.app = self
	local requ = lwf.create_request()
    local path = requ.path

    local page_found  = false
    -- match order by definition order
    for _, map in ipairs(self.route_map) do
		local k = map[1]
		local v = map[2]


        local args = {string.match(path, k)}
        if args and #args>0 then
			--print('Matched '..path..' '..k)
            page_found = true

            local resp = lwf.create_response()
            lwf.ctx.request  = requ
            lwf.ctx.response = resp

			lwf.ctx.session  = session.new(self.config.session)
			lwf.ctx.session:read(requ)

			if self.auth then
				-- Authentication
				self:identity()
			end

            if type(v) == "function" then                
                if lwfdebug then lwfdebug.debug_clear() end
                local ok, ret = pcall(v, requ, resp, unpack(args))
                if not ok then resp:error(ret) end
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args))
            else
                lwf.exit(500)
            end

			if self.auth then
				lwf.ctx.user = nil
			end
			lwf.ctx.session:write(resp)
			lwf.ctx.session:clear()
			resp:finish()
			resp:do_defers()
			resp:do_last_func()
            break
		else
			--print('Matching '..path..' '..k)
        end
    end

    if not page_found then
		--print('page_not_found path:'..path)
        lwf.exit(404)
    end
end

return {
	new = new
}
