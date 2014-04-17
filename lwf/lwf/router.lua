
local functional = require 'lwf.functional'
local util = require 'lwf.util'
local logger = require 'lwf.logger'
local lwfstatic = require 'lwf.static'
local controller = require 'lwf.controller'

local function route_sorter(l, r)
	local luri = l[1]
	local ruri = r[1]
    if #luri==#ruri then
        return luri < ruri
    else
        return #luri > #ruri
    end
end

local function _map(app, route_map, uri, func_name)
    local mod_name, fn = string.match(func_name, '^(.+):?(.-)$')
	mod_name = mod_name:gsub('%.', '/')
	local mod_file = app.config.controller..mod_name..'.lua'
	local env = {
		app = app,
		lwf = app.lwf,
		logger = logger,
	}
	setmetatable(env, {__index=_G})
	local _, h = util.loadfile(mod_file, env)
	if fn and fn ~= '' then
		h = h[fn]
	else
		h = h.handler or h.get
	end

	if h then
		table.insert(route_map, {uri, h})
	else
		local error_info = "LWF URL Mapping Error:[" .. uri .. "=>" .. func_name .. "] function or controller not found in module: " .. mod_file
		logger:error(error_info)
	end
end

local function map(app, route_map, uri, func_name)
    local ret, err = pcall(_map, app, route_map, uri, func_name)
    if not ret then
        local error_info = "LWF URL Mapping Error:[" .. uri .. "=>" .. func_name .. "] " .. err
        logger:error(error_info)
    end
end

local function create_map_func(app)
	local map = map
	local app = app
	local route_map = app.route_map
	return function(...)
		map(app, route_map, ...)
	end
end

local function static(app, route_map, uri, func_name)
	local s = lwfstatic.new(app, func_name)
	table.insert(route_map, {uri, s})
end

local function create_static_func(app)
	local static = static
	local app = app
	local route_map = app.route_map
	return function(...)
		static(app, route_map, ...)
	end
end

local function setup(app, file)
	app.route_map = app.route_map or {}
	if app.config.static then
		table.insert(app.route_map, {'^/static/(.+)', lwfstatic.new(app, app.config.static)})
	end
	local env = {}
	env.map = create_map_func(app)
	env.static = create_static_func(app)
	env.print = print
	
	util.loadfile(file, env)

	if app.config.router and  app.config.router == 'auto' then
		table.insert(app.route_map, {'^/(.-)$', controller.new(app, app.config.controller)})
	end
end

function merge_routings(main_app, subapps)
    local main_routings = main_app.route_map

    for _, sub in pairs(subapps) do
        local sub_routings = sub.app.route_map

        for _, map in pairs(sub_routings) do
			local sk = map[1]
			local sv = map[2]

			sk = sk:match('%^/(.+)$') or sk
			table.insert(main_routings, {'^/'..sub.name..'/'..sk, sv})
		end
    end

    table.sort(main_routings, route_sorter)
end

return {
	setup = setup,
	merge_routings = merge_routings,
}
