
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local url = require 'socket.url'
local cjson = require 'cjson'
local zlib_loaded, zlib = pcall(require, 'zlib')

local URL = nil
local GZIP = nil

local api = {
	init = function (srv_url, timeout, gzip)
		URL = srv_url
		GZIP = gzip
		http.TIMEOUT = timeout or 5
	end,
}

function api.post(obj)
	local u = url.parse(URL, {path='', scheme='http'})

	local rstring = obj and cjson.encode(obj) or ''
	--print('JSON', rstring)
	if GZIP and zlib_loaded then
		rstring = zlib.compress(rstring, 9, nil, 15 + 16)
	end

	local re = {}

	u.source = ltn12.source.string(rstring)
	u.sink, re = ltn12.sink.table(re)
	u.method = 'POST'
	u.headers = {}
	u.headers["content-length"] = string.len(rstring)
	--print(string.len(rstring))
	u.headers["content-type"] = "application/json;charset=utf-8"

	if GZIP and zlib_loaded then
		u.headers["content-encoding"] = "gzip"
	end

	local r, code, headers, status = http.request(u)
	--print(r, code)--, pp(headers), status)

	if r and code == 200 then
		return true, table.concat(re)
	else
		local err = 'Error: code['..(code or 'Unknown')..'] status ['..(status or '')..']'
		print(err)
		return nil, err
	end
end

function api.get(query)
	local query = url.escape(query)
	local u = url.parse(URL, {path='', scheme='http'})

	u.query = u.query and u.query..'&q='..query or 'q='..query

	local re = {}

	u.sink, re = ltn12.sink.table(re)
	u.method = 'GET'
	u.headers = {}
	u.headers["content-length"] = 0
	u.headers["content-type"] = "application/json;charset=utf-8"

	local r, code, headers, status = http.request(u)
	--print(r, code)--, pp(headers), status)

	if r and code == 200 then
		return true, table.concat(re)
	else
		local err = 'Error: code['..(code or 'Unknown')..'] status ['..(status or '')..']'
		print(err)
		return nil, err
	end
end


local _M = {}
local class = {}

_M.new = function(m)
	local obj = {
		lwf = m.lwf,
		app = m.app,
	}
	return setmetatable(obj, {__index=class})	
end

function class:init()
	--api.init("http://localhost:8086/db/rtdb/series?u=test&p=test", 2, false)
	api.init("http://114.215.144.20:8086/db/rtdb/series?u=test&p=test", 2, false)
end

function class:close()
end

function class:list(key, path, len)
	local len = len or 10240
	local name = key..'.'..path
	local query = 'select * from "'..name..'" limit '..len..';'
	local r, data = api.get(query)
	if r then
		local r, jdata = pcall(cjson.decode, data)
		if not r then
			return nil, data
		end

		if #jdata == 0 then
			return nil, 'No value in database'
		end
		assert(#jdata == 1)
		local points = jdata[1].points
		local rdata = {}
		for _, v in ipairs(points) do
			rdata[#rdata + 1] = {timestamp=v[1], value=v[4], quality=v[3]}
		end
		return rdata
	else
		return nil, data
	end

end

function class:get(key, path)
	local r, err = self:list(key, path, 1)
	if r then
		return r[1]
	end
	return nil, err
end

function class:add(key, path, list)
	local data = {}
	data.name = key..'.'..path
	data.columns = {"time", "value", "quality"}
	data.points = {}
	for _, v in ipairs(list) do
		data.points[#data.points + 1] = {v.timestamp or 0, v.value or 0, v.quality or 0}
	end
	local r, err = api.post({data})
	if not r then 
		print(err)
		return nil, err
	end
	return true
end

return _M
