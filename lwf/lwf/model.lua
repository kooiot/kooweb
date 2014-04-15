--
-- Model 
local util = require 'lwf.util'
local logger = require 'lwf.logger'

local _M = {}
local class = {}

function _M.new (lwf, path)
	assert(lwf)
	assert(path)
	local obj = {
		lwf = lwf,
		path = path,
		-- _cache = {},
	}
	return setmetatable(obj, {__index=class})
end

function class:get(name)
	if self._cache and self._cache[name] then
		return self._cache[name](self)
	end

	local filename = self.path..name..'.lua'
	local r, model = util.loadfile(filename)
	if not r then
		logger:error('Failed to load model '..name, model)
		return nil
	end
	if not model then
		logger:error('You should add return table in your model '..name, model)
		return nil
	end

	if model.new then
		if self._cache then
			self._cache[name] = model.new
		end
		return model.new(self)
	end
end

return _M

