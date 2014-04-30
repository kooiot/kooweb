#!/usr/bin/env lua

local platform = require 'lwf.platform'
local application = require 'lwf.application'
local logger = require 'lwf.logger'

local function get_apps(app_name)
	local inited = inited or {}
	return inited[app_name]
end

local function setup(lwf)
	local lwf = lwf
	local function setup_app(ctx)
		lwf.home = lwf.var.LWF_HOME or os.getenv("LWF_HOME")

		local app_name = lwf.var.LWF_APP_NAME
		local app_path = lwf.var.LWF_APP_PATH

		lwf.current_app = application.new(lwf, app_name, app_path)

		return lwf.current_app
	end

	local function content()
		local ctx = lwf.ctx

		local app_name = lwf.var.LWF_APP_NAME
		local ok, app = pcall(setup_app)

		--if not ok then
		if not ok then
			local error_info = "LWF APP SETUP ERROR: " .. app
			lwf.set_status(500)
			lwf.say(error_info)
			logger:error(error_info)
			return
		else
			return app:dispatch()
		end
	end

	return content
end

return setup
