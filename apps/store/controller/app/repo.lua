return {
	--[[
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
	]]--
	get = function(req, res)
		local db = app.model:get('db')
		db:init()
		local apps = db:list_all()
		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'
		local callback = req:get_arg('callback')
		if not callback then
			res:write(cjson.encode(apps))
		else
			res:write(callback)
			res:write('(')
			res:write(cjson.encode(apps))
			res:write(')')
		end
	end
}
