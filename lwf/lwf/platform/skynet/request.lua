
local util = require 'lwf.util'
local req = require 'lwf.platform.skynet.req'
local Request = {}

local get_headers = function(env)
	local headers = {}
	local header = env.header
	headers['Host']= header.host
	headers['User-Agent'] = header['user-agent']
	headers['Accept'] = header.accept
	headers['Accept-Language'] = header['accept-language']
	headers['Accept-Encoding'] = header['accept-encoding']
	headers['Cookie'] = header.cookie
	headers['Connection'] = header.connection
	headers['if-modified-since'] = header['if-modified-since']
	headers['last-modified'] = header['last-modified']
	headers['Referer'] = header.referer
	headers['Content-Type'] = header['content-type']
	headers['Content-Length'] = header['content-length']
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
		user_agent      = env.header["user-agent"],
		--remote_addr     = env.REMOTE_ADDR,
		--remote_port     = env.REMOTE_PORT,
		content_type    = env.header["content-type"],
		content_length  = tonumber(env.header["content-length"]) or 0,
		uri_args        = t.GET,
		post_args	= t.POST,
		cookies		= t.cookies,
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
