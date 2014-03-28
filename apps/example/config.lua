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

	debug={
		on = true,
		to = "response", -- "logger"
	},

	subapps={
		--demo3 = {path="/path/to/subapp", config={}},
	},
}
