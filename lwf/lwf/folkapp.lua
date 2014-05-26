
local util = require 'lwf.util'
local router = require 'lwf.router'
local lwfdebug = require 'lwf.debug'
local session = require 'lwf.session'
local model = require 'lwf.model'
local logger = require 'lwf.logger'
local i18n = require 'lwf.i18n'

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

local function new(lwf, baseapp, name, path)
	local app = {
		lwf = lwf,
		base_app = baseapp,
		app_name = name,
		app_path = path,
	}
        
	local c = {}
	translate_config(path, c)
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
	router.setup(self)
    
    if self.debug and self.debug.on and lwfdebug then
        debug.sethook(debug.debug_hook, "cr")
    end

	-- I18N loading
	if self.base_app.config.i18n then
		local po = require 'lwf.util.po'
		local dir = require 'lwf.util.dir'
		dir.do_each(self.app_path..'/i18n', function(path)
			local lang = path:match('.+/[^/]+$')
			po.attach(path, lang)
			--- 
		end)
		self.translations = po.get_translations()
	else
		self.translations = {}
	end
end

function class:authenticate(username, password, ...)
	return self.base_app:authenticate(username, password, ...)
end

function class:get_translator()
	local session = self.ctx.session 
	local lang = nil
	if session then
		lang = session:get('lang') or util.guess_lang(self.lwf.ctx.request)
	end

	if self.base_app then
		local ft = self.base_app.translations
		local translator = i18n.make_translator(self.translations, lang)
		local basetransaltor = i18n.make_translator(ft, lang)
		return i18n.make_translator(translator, basetransaltor)
	else
		return i18n.make_translator(self.translations, lang)
	end
end



function class:dispatch(requ, resp, path)
	local lwf = self.lwf
	local ctx = lwf.ctx
	local requ = requ or ctx.request
	local resp = resp or ctx.response
    local path = path or requ.path

	ctx.app = self

    local page_found  = false
    -- match order by definition order
    for _, map in ipairs(self.route_map) do
		local k = map[1]
		local v = map[2]

        local args = {string.match(path, k)}
        if args and #args>0 then
			--print('Matched '..path..' '..k)
            page_found = true

            if type(v) == "function" then                
                if lwfdebug then lwfdebug.debug_clear() end
                local ok, ret = pcall(v, requ, resp, unpack(args))
                if not ok then resp:error(ret) end
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args))
            else
                lwf.exit(500)
            end

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
