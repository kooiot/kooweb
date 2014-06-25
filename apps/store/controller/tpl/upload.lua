return {
	post = function(req, res)
		req:read_body()
		local cjson = require 'cjson'
		print(cjson.encode(req.post_args))
		res:write(cjson.encode(req.post_args))
	end
}
