
local functional = require 'lwf.functional'
local util = require 'lwf.util'
local logger = require 'lwf.logger'

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
    local mod_name, fn = string.match(func_name, '^(.+)%.([^.]+)$')
	local mod_file = app.app_path..'/app/'..mod_name..'.lua'
	local _, h = util.loadfile_with_env(mod_file)
    local func = h[fn]
    if func then
        table.insert(route_map, {uri, func})
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

local function setup(app, file)
	app.route_map = app.route_map or {}
	local env = {}
	env.map = create_map_func(app)
	env.print = print
	
	util.loadfile_with_env(file, env)
end

function merge_routings(main_app, subapps)
    local main_routings = main_app.route_map

    for k, sub in pairs(subapps) do
        local sub_routings = sub.app.route_map

        for sk,sv in pairs(sub_routings) do
			main_routings[sk]=sv
		end
    end

    table.sort(main_routings, route_sorter)
end

return {
	setup = setup,
	merge_routings = merge_routings,
}
