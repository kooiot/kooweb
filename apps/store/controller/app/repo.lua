return {
	get = function(req, res)
		local folder = (app.config.static or app.app_path..'/static')..'/releases'
		local f, err = loadfile(folder..'/release.lua')
		if not f then
			logger:error(err)
			lwf.exit(404, err)
		else
			local r, t = pcall(f)
			if not r then
				logger:error(t)
				lwf.exit(404)
			else
				local cjson = require 'cjson'
				local util = require 'lwf.util'
				logger:debug(cjson.encode(t))
				res.headers['Content-Type'] = 'application/json'
				res:write(cjson.encode(t))
			end
		end
	end
}
