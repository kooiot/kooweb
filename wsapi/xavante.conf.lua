local redirecthandler = require "xavante.redirecthandler"
local filehandler = require "xavante.filehandler"
local lwfhandler = require 'lwfhandler'
local wsx = require "wsapi.xavante"

local function addrule(rule)
  rules[#rules+1] = rule
end

addrule{ -- URI remapping example
  match = "^/static/(.+)",
  with = filehandler,
  params = {baseDir = os.getenv('LWF_APP_PATH') or '/home/cch/kooweb/apps/example/'}
}

local launcher_params = {
	isolated = true,
	reload = reload,
	period = period or ONE_HOUR,
	ttl = ttl or ONE_DAY
}

local handler = wsx.makeGenericHandler (docroot, launcher_params)

addrule{ -- URI remapping example
	match = "^(.+)",
	with = lwfhandler('lwf.ws', handler),
}

