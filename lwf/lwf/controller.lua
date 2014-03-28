
local lwfdebug=require("lwf.debug")

local function default_handler(request,response,...)
	print('default_handler')
    ngx.exit(403)
end

local Controller={}

local function new(app, path)
	local path = path or app.app_path..'/controller/'
    local o = {app = app, path = path}
    return setmetatable(o, {_class=Controller})
end

function load_fp(filename)
	local filename = self.path..filename..'.lua'
	local r, fp = util.loadfile_with_env(filename)
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
    local method=string.lower(request.method)

	local filename = table.concat({...})
	local fp = load_fp(filename)
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

    response:finish()
    response:do_defers()
    response:do_last_func()
end

return {
	new = new
}

