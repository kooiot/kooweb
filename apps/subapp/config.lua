--
-- This is a LWF Application Config file
-- 
--
return {
	static = 'static', -- default will not enable static file access

	session={
		key			= 'lwfsession', -- default is lwfsession
		pass_salt   = '8C7f8lProgw3U4IvVyDqk38bD0HAD8hBBfHZRMRF',
		salt		= 'tdzd77zTw3aHW8IqZgQteXUG3s5kFMQZQf2ODSXZ',
	},

	debug={
		on = true,
		to = "response", -- "logger"
	},

	subapps={
		--subinsub = {path="/home/cch/kooweb/apps/subappinsub", config={}},
	},
}
