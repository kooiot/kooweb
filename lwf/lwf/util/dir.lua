local _M = {}

function _M.scan(directory)
	local t = {}
	for filename in io.popen('ls -a "'..directory..'"'):lines() do
		if filename ~= '.' and filename ~= '..' then
			t[#t + 1] = directory..'/'..filename
		end
	end
	return t
end

function _M.scan_file(directory, ext)
	local t = _M.scan(directory)
	if not ext then
		return t
	end

	local pattern = '%.'..ext..'$'
	for k, v in pairs(t) do
		if not v:match(pattern) then
			t[k] = nil
		end
	end
	return t
end

function _M.do_each(directory, func, ext)
	local t = _M.scan_file(directory, ext)
	if t then
		for k, v in pairs(t) do
			func(v)
		end
	end
end

return _M
