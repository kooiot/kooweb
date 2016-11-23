
local util = require 'lwf.util'
local req = require 'lwf.platform.skynet.req'
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
	headers['Referer'] = env.HTTP_REFERER
	return headers
end

local function new(lwf)
	local env = lwf.ctx.sky_env
	local t = req.new(env)

	local ret = {
		lwf		= lwf,
		method          = env.method,
		schema          = 'http',
		host            = env.host,
		hostname        = env.host:match('^[^:]+.*&'),
		uri             = env.url, --the full uri
		path            = env.path, --ngx_var.uri,  -- the uri without query string
		filename        = env.script_name,
		query_string    = env.query,
		headers         = get_headers(env),
		user_agent      = env.HTTP_USER_AGENT,
		remote_addr     = env.REMOTE_ADDR,
		remote_port     = env.REMOTE_PORT,
		content_type    = env.CONTENT_TYPE,
		content_length  = env.CONTENT_LENGTH,
		uri_args        = t.GET,
		post_args	= t.POST,
		socket          = env.socket,
		cookies		= env.cookies,
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
	local arg = self:get_post_arg(name) or self:get_uri_arg(name)
    return arg or default
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
