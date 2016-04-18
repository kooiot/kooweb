
local util = require 'lwf.util'
local router = require 'lwf.router'
local lwfdebug = require 'lwf.debug'
local session = require 'lwf.session'
local model = require 'lwf.model'
local logger = require 'lwf.logger'
local i18n = require 'lwf.i18n'

local unpack = table.unpack or unpack

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
	self.model = model.new(self.lwf, self.config.model)

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
		self.auth = require('lwf.auth')(self.lwf, self, authconfig)
		assert(self.auth)
	end

	-- I18N loading
	if self.config.i18n then
		local po = require 'lwf.util.po'
		local dir = require 'lwf.util.dir'
		dir.do_each(self.app_path..'/i18n', function(path)
			local lang = path:match('.+/([^/]+)$')
			--print('loading i18n from ', path, ':', lang)
			po.attach(path, lang)
			--- 
		end)
		self.translations = po.get_translations()
	else
		self.translations = {}
	end
end

function class:get_translator()
	local session = self.lwf.ctx.session 
	local lang = nil
	if session then
		lang = session:get('lang') or util.guess_lang(self.lwf.ctx.request)
	end

	if self.base_app then
		local ft = self.base_app.translations
		local translator = i18n.make_translator(self.translations, lang)
		local basetransaltor = i18n.make_translator(ft, lang)
		return i18n.make_fallback(translator, basetransaltor)
	else
		return i18n.make_translator(self.translations, lang)
	end
end

function class:dispatch()
	local lwf = self.lwf
	local ctx = lwf.ctx
	ctx.app = self
	local requ = lwf.create_request()
    local path = util.unescape_url(requ.path)

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
				ctx.auth = self.auth.create()
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
				self.auth.close(ctx.auth)
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
