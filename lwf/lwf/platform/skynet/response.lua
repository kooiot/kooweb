
local util			= require 'lwf.util'
local lwfdebug		= require 'lwf.debug'
local functional	= require 'lwf.functional'
local ltp			= require 'lwf.template'
local logger		= require 'lwf.logger'

local Response={ltp=ltp}

local function new(lwf)
	local _res = lwf.ctx._res
	local ret={
		lwf = lwf,
		headers = _res.headers,
		_res = _res,
		_cookies={},
		_defer={},
		_last_func=nil,
		_eof=false
	}
	return setmetatable(ret, {__index=Response})
end

function Response:set_last_func(func, ...)
    self._last_func = functional.curry(func, ...)
end

function Response:do_last_func()
    local last_func = self._last_func
    if last_func then
        local ok, err = pcall(last_func)
        if not ok then
            logger:e('Error while doing last func: %s', err)
        end
    end
end

function Response:defer(func, ...)
    table.insert(self._defer, functional.curry(func, ...))
end

function Response:do_defers()
    if self._eof==true then
        for _, f in ipairs(self._defer) do
            local ok, err = pcall(f)
            if not ok then
                logger:error('Error while doing defers: %s', err)
            end
        end
    else
        logger:error("response is not finished")
    end
end

function Response:write(content)
    if self._eof==true then
        local error_info = "Moochine WARNING: The response has been explicitly finished before."
        logger:warn(error_info)
        return
    end

	self._res:write(content)
end

function Response:writeln(content)
    if self._eof==true then
        local error_info = "Moochine WARNING: The response has been explicitly finished before."
        logger:warn(error_info)
        return
    end

    self._res:write(content)
    self._res:write("\r\n")
end

function Response:redirect(url, status)
	self._res.status = status or 302
	self._res:redirect(url)
	self:finish()
end

function Response:_set_cookie(key, value, duration, path)
    if not value then return nil end
    
    if not key or key=="" or not value then
        return
    end

	key = util.escape_url(key)
	value = util.escape_url(value)

    if not duration or duration < 0 then
        duration=604800 -- 7 days, 7*24*60*60 seconds
    end

    if not path or path=="" then
        path = "/"
    end

	if duration ~= 0 then
		local expiretime = os.time() + duration
		expiretime = os.date('!%a, %d %b %Y %X GMT', expiretime)
		return table.concat({key, "=", value, "; expires=", expiretime, "; path=", path})
	else
		return table.concat({key, "=", value, "; path=", path})
	end
end

function Response:set_cookie(key, value, duration, path)
    local cookie=self:_set_cookie(key, value, duration, path)
    self._cookies[key]=cookie
    self.headers["Set-Cookie"] = functional.table_values(self._cookies)
end

function Response:debug()
    local debug_conf = self.lwf.debug
    local target = "logger"
    if debug_conf and type(debug_conf)=="table" then target = debug_conf.to or target end
    if target=="response" and string.match(self.headers['Content-Type'] or '', '^text/.*html') then
        -- seems to be no way to get default_type?
        self:write(lwfdebug.debug_info2html())
    elseif target=="logger" then
        logger:debug(lwfdebug.debug_info2text())
    end
    lwfdebug.debug_clear()
end

function Response:error(info)
    local error_info = "LWF ERROR: " .. info
    if self._eof==false then
        self._res.status=500
        self.headers['Content-Type'] = 'text/html; charset=utf-8'
        self:write(error_info)
		self:write(debug.traceback())
    end
    logger:error(error_info)
end

function Response:is_finished()
    return self._eof
end

function Response:finish()
    if self._eof==true then
        return
    end

    local debug_conf = self.lwf.debug
    if debug_conf and type(debug_conf)=="table" and debug_conf.on then
        self:debug()
    end

    self._eof = true
end

function Response:sendfile(filename)
	local str = util.read_all(filename)
	self:write(str)
end

return {
	new = new
}
