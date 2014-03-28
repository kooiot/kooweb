#!/usr/bin/env lua

local platform = require 'lwf.platform'
local application = require 'lwf.application'
local logger = require 'lwf.logger'

local function get_apps(app_name)
	local inited = inited or {}
	return inited[app_name]
end

local function setup_app(ctx)
    lwf.home = lwf.var.LWF_HOME or os.getenv("LWF_HOME")

    local app_name = lwf.var.LWF_APP_NAME
    local app_path = lwf.var.LWF_APP_PATH

	lwf.app = application.new(lwf, app_name, app_path)

	return lwf.app
end

local function content()
	lwf = platform('nginx')

    local ctx = lwf.ctx

    local app_name = lwf.var.LWF_APP_NAME
	local ok, app = pcall(setup_app)

	if not ok then
		local error_info = "LWF APP SETUP ERROR: " .. app
		lwf.status = 500
		lwf.say(error_info)
		-- logger:e(error_info)
		lwf.log(lwf.ERR, error_info)
		return
	end

	return app:dispatch()
end

----------
content()
----------

