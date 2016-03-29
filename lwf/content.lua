#!/usr/bin/env lua
local setup = require 'setup'

local lwf, content = setup('nginx')
ngx.ctx.lwf = content
---------
content()
----------

