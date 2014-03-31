
local util = require 'lwf.util'
local router = require 'lwf.router'
local lwfdebug = require 'lwf.debug'
local session = require 'lwf.session'

local class = {}

local function concat_path(base, path, default)
	local path = path or default
	if path[1] ~= '/' then
		path = base..'/'..path
	end
	return path..'/'
end

local function translate_config(path, c)
	c.config = c.config or {}
	c.config.templates = concat_path(path, c.config.templates, 'templates')
	c.config.controller = concat_path(path, c.config.controller, 'controller')
	local static = c.config.static
	if static then
		c.config.static = concat_path(path, static, 'static')
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
	}
        
    local app_config = path .. "/config.lua"
    local r, c = util.loadfile(app_config, app)
	assert(r)
	assert(c)
	translate_config(path, c)
	if c.session then
		translate_session(c)
	end
	for k, v in pairs(c) do
		app[k] = v
	end
	assert(app.app_name)
	assert(app.app_path)
	assert(app.lwf)

	local obj = setmetatable(app, {__index=class})
	obj:init()

	return obj
end

function class:init()
	local has_subapps = type(self.subapps) == "table" and #self.subapps ~= 0
    
    if has_subapps then
        for k, t in pairs(self.subapps) do
			t.app = new(self.lwf, k, t.path)
        end
    end

    -- load the main-app's routing
    local rfile = self.app_path .. "/routing.lua"
	router.setup(self, rfile)
    
    if has_subapps then
		-- merge routings
		router.merge_routings(self, self.subapps or {})
	end

    if self.debug and self.debug.on and lwfdebug then
        debug.sethook(debug.debug_hook, "cr")
    end
	
	if self.config.auth then
		self.auth = require('lwf.auth.'..self.config.auth).new(self.lwf, self)
		assert(self.auth)
	end
end

function class:create_user()
	local user = {
		username = username,
		-- TODO: more user meta
	}
	return user
end

function class:authenticate()
	local session = self.lwf.ctx.session
	local username = session:get('username')
	local password = session:get('password')
	if username and password then
		local r, err = self.auth:autheticate(username, password)
		if r then
			local user = self:create_user()
			self.lwf.ctx.user = user
		end
	end
end

function class:dispatch()
	local lwf = self.lwf
    local uri = lwf.var.REQUEST_URI
	local ctx = lwf.ctx

    local page_found  = false
    -- match order by definition order
    for _, map in ipairs(self.route_map) do
		local k = map[1] -- pattern
		local v = map[2] -- handler

        local args = {string.match(uri, k)}
        if args and #args>0 then
			--print('Matched '..uri..' '..k)
            page_found = true

            local requ = lwf.create_request()
            local resp = lwf.create_response()
            lwf.ctx.request  = requ
            lwf.ctx.response = resp

			lwf.ctx.session  = session.new(self.session)
			lwf.ctx.session:read(requ)

			-- Authentication
			self:authenticate()

            if type(v) == "function" then                
                if lwfdebug then lwfdebug.debug_clear() end
                local ok, ret = pcall(v, requ, resp, unpack(args))
                if not ok then resp:error(ret) end
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args))
            else
                lwf.exit(500)
            end

			lwf.ctx.session:write(resp)
			resp:finish()
			resp:do_defers()
			resp:do_last_func()
            break
		else
			--print('Matching '..uri..' '..k)
        end
    end

    if not page_found then
		--print('page_not_found uri:'..uri)
        lwf.exit(404)
    end
end

return {
	new = new
}
