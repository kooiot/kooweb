
local util = require 'lwf.util'
local Request = {}

local function new(lwf)
    local ngx_var = ngx.var
    local ngx_req = ngx.req
    local ret = {
		lwf				= lwf,
        method          = ngx_var.request_method,
        schema          = ngx_var.schema,
        host            = ngx_var.host,
        hostname        = ngx_var.hostname,
        uri             = ngx_var.request_uri,
        path            = ngx_var.uri,
        filename        = ngx_var.request_filename,
        query_string    = ngx_var.query_string,
        headers         = ngx_req.get_headers(),
        user_agent      = ngx_var.http_user_agent,
        remote_addr     = ngx_var.remote_addr,
        remote_port     = ngx_var.remote_port,
        remote_user     = ngx_var.remote_user,
        remote_passwd   = ngx_var.remote_passwd,
        content_type    = ngx_var.content_type,
        content_length  = ngx_var.content_length,
        uri_args        = ngx_req.get_uri_args(),
        socket          = ngx_req.socket,
		cookies			= nil,
    }

    return setmetatable(ret, {__index=Request})
end

function Request:get_uri_arg(name, default)
    if name==nil then return nil end

    local arg = self.uri_args[name]
    if arg~=nil then
        if type(arg)=='table' then
            for _, v in ipairs(arg) do
                if v and string.len(v)>0 then
                    return v
                end
            end

            return ""
        end

        return arg
    end

    return default
end

function Request:get_post_arg(name, default)
    if name==nil then return nil end
    if self.post_args==nil then return nil end

    local arg = self.post_args[name]
    if arg~=nil then
        if type(arg)=='table' then
            for _, v in ipairs(arg) do
                if v and string.len(v)>0 then
                    return v
                end
            end

            return ""
        end

        return arg
    end

    return default
end

function Request:get_arg(name, default)
    return self:get_post_arg(name, default) or self:get_uri_arg(name, default)
end

function Request:read_body()
    local ngx_req = ngx.req
    ngx_req.read_body()
    self.post_args = ngx_req.get_post_args()
end

function Request:get_cookie(key)
	if self.cookies then
		return self.cookies[key]
	end

	local s_cookie = self.headers['Cookie']
	self.cookies = util.parse_cookie_string(s_cookie)
	return self.cookies[key]
end

--[[
function Request:rewrite(uri, jump)
    return ngx.req.set_uri(uri, jump)
end

function Request:set_uri_args(args)
    return ngx.req.set_uri_args(args)
end
]]--
return {
	new = new
}
