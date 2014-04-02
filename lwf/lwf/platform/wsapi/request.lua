
local util = require 'lwf.util'
local wsapi_request = require 'wsapi.request'
local Request = {}

local get_headers = function(env)
	local headers = {}
	headers['Host']= env.HTTP_HOST
	headers['User-Agent'] = env.HTTP_USER_AGENT
	headers['Accept'] = env.HTTP_ACCEPT
	headers['Accept-Language'] = env.HTTP_ACCEPT_LANGUAGE
	headers['Accept-Encodeing'] = env.HTTP_ACCEPT_ENCODING
	headers['Cookie'] = env.HTTP_COOKIE
	headers['Connection'] = env.HTTP_CONNECTION
	headers['if-modified-since'] = env.IF_MODIFIED_SINCE
	headers['last-modified'] = env.LAST_MODIFIED
	return headers
end

local function new(lwf)
	assert(lwf.ctx.wsapi_env, 'No wsapi_env specified!!!!')
	local wsapi_req = wsapi_request.new(lwf.ctx.wsapi_env)
	local env = wsapi_req.env

    local ret = {
		lwf				= lwf,
		wsapi_req		= wsapi_req,
        method          = wsapi_req.method,
        schema          = 'http',
        host            = env.HTTP_HOST,
        hostname        = env.HTTP_HOST:match('^[^:]+.*&'),
        uri             = wsapi_req.path_info, --ngx_var.request_uri, --the full uri
        path            = wsapi_req.path_info, --ngx_var.uri,  -- the uri without query string
        filename        = wsapi_req.script_name,
        query_string    = wsapi_req.query_string,
        headers         = get_headers(env),
        user_agent      = env.HTTP_USER_AGENT,
        remote_addr     = env.REMOTE_ADDR,
        remote_port     = env.REMOTE_PORT,
        content_type    = env.CONTENT_TYPE,
        content_length  = env.CONTENT_LENGTH,
        uri_args        = wsapi_req.GET,
		post_args		= wsapi_req.POST,
        socket          = wsapi_req.input,
		cookies			= wsapi_req.cookies,
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
end

function Request:get_cookie(key)
	if self.cookies then
		return self.cookies[key]
	end
end

return {
	new = new
}
