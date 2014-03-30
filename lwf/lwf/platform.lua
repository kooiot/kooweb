
return function(platform, ...)
	local pmn = 'lwf.platform.'..platform
	local p = require(pmn)
	return p.init(...)
end

