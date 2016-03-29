#!/usr/bin/env lua

local platform = require 'lwf.platform'
local application = require 'lwf.application'
local logger = require 'lwf.logger'

local function setup(plat)
	local lwf = platform(plat)

	local function setup_app()
		lwf.home = lwf.var.LWF_HOME or os.getenv("LWF_HOME")

		local app_name = lwf.var.LWF_APP_NAME
		local app_path = lwf.var.LWF_APP_PATH

		return application.new(lwf, app_name, app_path)
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

	return lwf, content
end

return setup
