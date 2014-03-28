
-----------------------------------------------------------------------------
-- Creates a logger instance.
-----------------------------------------------------------------------------
local function make_logger(module_name, params, level)
   if module_name then
      require("logging."..module_name)
      local logger, err = logging[module_name](unpack(params))
      assert(logger, "Could not initialize logger: "..(err or ""))
      if level then 
         require("logging")
         logger:setLevel(logging[level])
      end
      return logger
   else
      return {
         debug = function(self, ...) print('DEBUG: ', ...) end, -- do nothing
         info  = function(self, ...) print('INFO: ', ...) end,
         error = function(self, ...) print('ERROR: ', ...) end,
         warn  = function(self, ...) print('WARNING: ', ...) end,
      }
   end
end


local logger = make_logger()

return logger
