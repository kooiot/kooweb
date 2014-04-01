#!/usr/bin/env lua
local platform = require 'lwf.platform'
local setup = require 'setup'

local lwf = platform('nginx', lwf)
local content = setup(lwf)
---------
content()
----------

