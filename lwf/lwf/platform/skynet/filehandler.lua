local lfs = require "lfs"
local util = require "lwf.util"
local mime = require "lwf.platform.skynet.mime"
local enc = require "lwf.platform.skynet.encoding"
local err = require "lwf.platform.skynet.err"

-- gets the mimetype from the filename's extension
local function mimefrompath (path)
	local _,_,exten = string.find (path, "%.([^.]*)$")
	if exten then
		return mime [exten]
	else
		return nil
	end
end

-- gets the encoding from the filename's extension
local function encodingfrompath (path)
	local _,_,exten = string.find (path, "%.([^.]*)$")
	if exten then
		return enc [exten]
	else
		return nil
	end
end

-- on partial requests seeks the file to
-- the start of the requested range and returns
-- the number of bytes requested.
-- on full requests returns nil
local function getrange (req, f)
	local range = req.headers["range"]
	if not range then return nil end

	local s,e, r_A, r_B = string.find (range, "(%d*)%s*-%s*(%d*)")
	if s and e then
		r_A = tonumber (r_A)
		r_B = tonumber (r_B)

		if r_A then
			f:seek ("set", r_A)
			if r_B then return r_B + 1 - r_A end
		else
			if r_B then f:seek ("end", - r_B) end
		end
	end

	return nil
end

-- sends data from the open file f
-- to the response object res
-- sends only numbytes, or until the end of f
-- if numbytes is nil
local function sendfile (f, res, numbytes)
	local block
	local whole = not numbytes
	local left = numbytes
	local blocksize = 8192

	if not whole then blocksize = math.min (blocksize, left) end

	while whole or left > 0 do
		block = f:read (blocksize)
		if not block then return end
		if not whole then
			left = left - string.len (block)
			blocksize = math.min (blocksize, left)
		end
		res:send_data (block)
	end
end

local function in_base(path)
	local l = 0
	if path:sub(1, 1) ~= "/" then path = "/" .. path end
	for dir in path:gmatch("/([^/]+)") do
		if dir == ".." then
			l = l - 1
		elseif dir ~= "." then
			l = l + 1
		end
		if l < 0 then return false end
	end
	return true
end

-- main handler
local function filehandler (app, baseDir, req, res, relpath)
	local lwf = app.lwf
	print('filehandler relpath', relpath)

	if req.method ~= "GET" and req.method ~= "HEAD" then
		print('405')
		return lwf.exit(405)
	end

	if not in_base(relpath) then
		print('403')
		return lwf.exit(403)
	end

	local path = baseDir .."/".. relpath

	res.headers ["Content-Type"] = mimefrompath (path)
	res.headers ["Content-Encoding"] = encodingfrompath (path)

	print('filehandler path', path)
	local attr = lfs.attributes (path)
	if not attr then
		return lwf.exit(404)
	end
	assert (type(attr) == "table")
	print('send....')

	if attr.mode == "directory" then
		req.parsed_url.path = req.parsed_url.path .. "/"
		return res:redirect(util.build_url (req.parsed_url))
	end

	res.headers["Content-Length"] = attr.size

	local f = io.open (path, "rb")
	if not f then
		return lwf.exit(404)
	end

	res.headers["last-modified"] = os.date ("!%a, %d %b %Y %H:%M:%S GMT",
	attr.modification)

	local lms = req.headers["if-modified-since"] or 0
	local lm = res.headers["last-modified"] or 1
	if lms == lm then
		return lwf.exit(304)
	end


	if req.method == "GET" then
		local range_len = getrange (req, f)
		if range_len then
			lwf.set_status(206)
			res.headers["Content-Length"] = range_len
		end

		sendfile (f, res, range_len)
	end
	f:close ()
end


return function (app, baseDir)
	if type(baseDir) == "table" then baseDir = baseDir.baseDir end
	return function (req, res, ...)
		return filehandler (app, baseDir, req, res, ...)
	end
end

