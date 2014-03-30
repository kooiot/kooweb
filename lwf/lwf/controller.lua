
local lwfdebug = require 'lwf.debug'
local util = require 'lwf.util'
local logger = require 'lwf.logger'

local function default_handler(request,response,...)
	print('default_handler')
    ngx.exit(403)
end

local Controller={}

local function new(app, path)
	local path = path or app.app_path..'/controller/'
    local o = {app = app, path = path, __name="Controller"}
    return setmetatable(o, {__index=Controller})
end

function Controller:__load_fp(filename)
	local filename = self.path..filename..'.lua'
	local env = {
		lwf=self.app.lwf,
		app=self.app
	}

	local r, fp = util.loadfile(filename, env)
	--local r, fp = util.loadfile_as_table(filename, env)
	if not r then
		logger:error(fp)
	end
	return fp or {}
end

-- HTTP Other Methods
function Controller:dummy_handler(request,response,...)
    default_handler(request,response,...)
end


-- Handle the Resuqt:
function Controller:_handler(request,response,...)
	local app = self.app
	local lwf = self.app.lwf
    local method=string.lower(request.method)

	local app_name, filename = string.match(table.concat({...}), '^([^/]+)/?(.-)$')
	app_name = app_name or self.app.app_name
	assert(app_name == self.app.app_name)
	if not filename or filename == "" then
		filename = 'index'
	end

	local fp = self:__load_fp(filename)
    local handler= fp[method] or function(...) return 
		self:dummy_handler(...)
	end

    local args={...}
    lwfdebug.debug_clear()
	local ok, ret=pcall( function()
		if type(handler)=="function" then
			-----
			if fp.before then
				fp.before(request,response, unpack(args))
			end
			-----
			handler(request, response, unpack(args))
			-----
			if fp.after then
				fp.after(request,response, unpack(args))
			end
		end
	end)

    if not ok then
		response:error(ret)
	end
end

return {
	new = new
}

