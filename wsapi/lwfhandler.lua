-----------------------------------------------------------------------------
-- lwf.ws handler
-----------------------------------------------------------------------------
local httpd = require 'xavante.httpd'

return function (name, handler)
	local name = name or 'lwf.ws'
	local m = '^/'..name:gsub('%.', '%%.')
	local handler = handler
	return function (req, res)
		local path = req.relpath
		if not path:match(m) then
			if path == '/' then
				req.relpath = '/'..name
				req.parsed_url.path = '/'..name
			else
				req.relpath = '/'..name..path
				req.parsed_url.path = '/'..name..req.parsed_url.path
			end
		end

		return handler(req, res)
	end
end
