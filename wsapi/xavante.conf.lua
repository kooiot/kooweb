local redirecthandler = require "xavante.redirecthandler"
local filehandler = require "xavante.filehandler"

local function addrule(rule)
  rules[#rules+1] = rule
end

addrule{ -- URI remapping example
  match = "^/static/(.+)",
  with = filehandler,
  params = {baseDir = os.getenv('LWF_APP_PATH') or '/home/cch/kooweb/apps/store/'}
}

