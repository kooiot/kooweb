return {
	get = function(req, res)
		local redis = require 'resty.redis'
		res:ltp('index.html', {app=app, lwf=lwf})
	end
}
