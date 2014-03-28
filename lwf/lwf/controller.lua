
local lwfdebug=require("lwf.debug")

local function default_handler(request,response,...)
	print('default_handler')
    ngx.exit(403)
end

local Controller={}

local function new()
    local o={}
    return setmetatable(o, {_class=Controller})
end

function Controller:extend()
    local new_controler = new()
    return new_controller
end


-- FILTER
function Controller:before()
    -- do nothing
    return true
end


-- FILTER
function Controller:after()
    -- do nothing
    return true
end

--[[
  List of HTTP methods:

  * RFC 2616:
      OPTIONS,GET,HEAD,POST,PUT,DELETE,TRACE,CONNECT
  * RFC 2518
      PROPFIND,PROPPATCH,MKCOL,COPY,MOVE,LOCK,UNLOCK
  * RFC 3253
      VERSION-CONTROL,REPORT,CHECKOUT,CHECKIN,UNCHECKOUT,MKWORKSPACE,
      UPDATE,LABEL,MERGE,BASELINE-CONTROL,MKACTIVITY
  * RFC 3648
      ORDERPATCH
  * RFC 3744
      ACL
  * draft-dusseault-http-patch
      PATCH
  * draft-reschke-webdav-search
      SEARCH
--]]


-- HTTP GET
function Controller:get(request,response,...)
    default_handler(request,response,...)
    self.finished=true
end

-- HTTP POST
function Controller:post(request,response,...)
    default_handler(request,response,...)
    self.finished=true
end


-- HTTP PUT
function Controller:put(request,response,...)
    default_handler(request,response,...)
    self.finished=true
end


-- HTTP DELETE
function Controller:delete(request,response,...)
    default_handler(request,response,...)
    self.finished=true
end

-- HTTP Other Methods
function Controller:dummy_handler(request,response,...)
    default_handler(request,response,...)
    self.finished=true
end


-- Handle the Resuqt:
function Controller:_handler(request,response,...)
    local method=string.lower(ngx.var.request_method)
    local ctller=self:new()
    local handler=ctller[method] or ctller['dummy_handler']
    local args={...}
    lwfdebug.debug_clear()
    local ok, ret=pcall(
        function()
            if type(handler)=="function" then
                ctller:before(request,response)
                if ctller.finished==true then return end
                handler(ctller,request,response,unpack(args))
                if ctller.finished==true then return end
                ctller:after(request,response)
            end
        end)
    if not ok then response:error(ret) end
    response:finish()
    response:do_defers()
    response:do_last_func()
end

return {
	new = new
}
