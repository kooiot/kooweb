local ltp = require 'ltp.template'
local util = require 'lwf.util'

--
-- Uncomment this to enable cache in product env
-- local ltp_templates_cache={}


local function out (s, i, f)
	s = string.sub(s, i, f or -1)
	if s == "" then return s end
	-- we could use `%q' here, but this way we have better control
	s = string.gsub(s, "([\\\n\'])", "\\%1")
	-- substitute '\r' by '\'+'r' and let `loadstring' reconstruct it
	s = string.gsub(s, "\r", "\\r")
	return string.format(" %s('%s'); ", "out", s)
end

local function translate(s)
	s = string.gsub(s, "^#![^\n]+\n", "")
	s = string.gsub(s, "<%%(.-)%%>", "<?lua %1 ?>")
	--s = string.gsub(s, "<%?([^l][^u][^a].-)%?>", "<?lua %1 ?>")
	local res = {}
	local start = 1   -- start of untranslated part in `s'
	while true do
		local ip, fp, target, exp, code = string.find(s, "<%?(%w*)[ \t]*(=?)(.-)%?>", start)
		if not ip then break end
		table.insert(res, out(s, start, ip-1))
		if target ~= "" and target ~= "lua" then
			-- not for Lua; pass whole instruction to the output
			table.insert(res, out(s, ip, fp))
		else
			code = string.gsub(code, "(%-%-%[%[.-%]%]%-%-)", "")
			code = string.gsub(code, "(%-%-.+)", "")
			if exp == "=" then   -- expression?
				table.insert(res, string.format(" %s(%s);", 'out', code))
			else  -- command
				table.insert(res, string.format(" %s ", code))
			end
		end
		start = fp + 1
	end
	table.insert(res, out(s, start))
	return table.concat(res)
end

function __ltp_function(app, template)
	if ltp_templates_cache then
		ret=ltp_templates_cache[template]
	end
    if ret then return ret end
    local tdata=util.read_all(app.config.templates.. template)
	--[[ WE need not loading sub apps template for the param app's
    -- find subapps' templates
    if not tdata then
        tdata=(function(appname)
                   subapps = app.subapps or {}
                   for k,v in pairs(subapps) do
                       local d=util.read_all(v.app.config.templates .. template)
                       if d then return d end
                   end
               end)(app.app_name)
    end
	]]--
	if not tdata  then
		local capp = app.base_app
		while capp do
			tdata = util.read_all(capp.config.templates .. template)
			if tdata then
				break
			end
			capp = capp.base_app
		end
	end
	if not tdata then
		tdata = "Template file is not exist"
	end

	--local rfun = ltp.load_template(tdata, '<?','?>')
	local rfun = translate(tdata)
	if ltp_templates_cache then
		ltp_templates_cache[template]=rfun
	end
	--print('rfun='..rfun)
	return rfun
end

local extend
local include
local function execute_template(response, rfun, data)
	local output = {}

	data.out = function (data)
		table.insert(output, data)
	end

	local extends = {}
	data.extend = function(file)
		table.insert(extends, 1, file)
	end

	local f, err = load(rfun, nil, nil, data)
	if not f then
		return nil, err
	end
	f()

	for _, f in pairs(extends) do
		local extend = extend(response, data)
		output = extend(f, output)
	end

	return output
end

local function process (response, template, data)
	assert(data)
	assert(template)
	local lwf = response.lwf

	data.include = include(response, data)
    local rfun = __ltp_function(lwf.ctx.app, template)
	local mt={__index=_G}
	setmetatable(data,mt)
	--ltp.execute_template(rfun, data)
	return execute_template(response, rfun, data)
end

extend = function (response, data)
	return function(layout, contents)
		--print('extending '..layout)
		data.content = function()
			return contents
		end
		return process(response, layout, data)
	end
end

include = function (response, data)
	return function(template, tdata)
		local tdata = tdata or data
		--print('including '..template)
		data.out(process(response, template, tdata))
	end
end

return function(response, template, data)
	local lwf = response.lwf
	local data = data or {lwf=lwf, app=lwf.ctx.app}
	data.escape_url = util.escape_url
	assert(data)
	local output = process(response, template, data)
	--print('finished '..#output)
	response:write(output)
end
