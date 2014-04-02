local redirecthandler = require "xavante.redirecthandler"
local filehandler = require "xavante.filehandler"

local function addrule(rule)
  rules[#rules+1] = rule
end

addrule{ -- URI remapping example
  match = "^/static/(.+)",
  with = filehandler,
  params = {baseDir = '/home/cch/kooweb/apps/example/'}
}

