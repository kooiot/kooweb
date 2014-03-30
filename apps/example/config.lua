--
-- This is a LWF Application Config file
-- 
--
return {
	config={
		--templates = "templates", -- default is templates
		--controller = 'controller', -- default is controller
		static = 'static', -- default will not enable static file access
		router = 'auto', -- auto: restful controller.
	},
	session={
		key			= 'lwf_session', -- default is lwf_session
		pass_salt   = '8C7f8lProgw3U4IvVyDqk38bD0HAD8hBBfHZRMRF',
		salt		= 'tdzd77zTw3aHW8IqZgQteXUG3s5kFMQZQf2ODSXZ',
	},

	debug={
		on = true,
		to = "response", -- "logger"
	},

	subapps={
		--demo3 = {path="/path/to/subapp", config={}},
	},
}
