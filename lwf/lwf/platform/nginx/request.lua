
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
	local arg = self:get_post_arg(name) or self:get_uri_arg(name)
    return arg or default
end

local function parse_multipart()
	local out = { }
	local upload = require 'resty.upload'
	local input, err = upload:new(8192)
	if not (input) then
		return nil, err
	end

	input:set_timeout(1000)

	local current = {
		contents = { }
	}

	while true do
		local typ, res, err = input:read()

		if "body" == typ then
			table.insert(current.contents, res)
		elseif "header" == typ then
			local name, value = unpack(res)
			if name == "Content-Disposition" then
				do
					local params = util.parse_content_disposition(value)
					if params then
						for _index_0 = 1, #params do
							local tuple = params[_index_0]
							current[tuple[1]] = tuple[2]
						end
					end
				end
			else
				current[name:lower()] = value
			end
		elseif "part_end" == typ then
			current.contents = table.concat(current.contents)
			if current.name then
				if current["content-type"] then
					out[current.name] = current
				else
					out[current.name] = current.contents
				end
			end
			current = {
				contents = { }
			}
		elseif "eof" == typ then
			break
		else
			return nil, err or "failed to read upload"
		end
	end
	return out
end

function Request:read_body()
	local ngx_req = ngx.req
	if (self.headers["content-type"] or ""):match(util.escape_pattern("multipart/form-data")) then
		self.post_args =  parse_multipart() or { }
	elseif (self.headers["content-type"] or ""):match(util.escape_pattern("application/json")) then
		ngx_req.read_body()
		self.post_args = {}

		local file = ngx_req.get_body_file()
		local json_text = nil
		if file then
			local f, err = io.open(file)
			if f then
				json_text = f:read('*a')
				f:close()
			end
		else
			json_text = ngx_req.get_body_data() or ''
		end

		--- Decode the compressed content
		if self.headers["content-encoding"] == 'gzip' and string.len(json_text) > 0 then
			local zlib = require 'zlib'

			assert(string.len(json_text) == tonumber(self.headers["content-length"]))

			local decoded_json, err = zlib.decompress(json_text, 15 + 16)
			if not decoded_json then
				print(string.len(json_text), err)
			end

			json_text = decoded_json or ''
		end

		self.post_args['json'] = json_text
	else
		ngx_req.read_body()
		self.post_args = ngx_req.get_post_args()
	end
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
