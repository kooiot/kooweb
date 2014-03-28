--
-- This is a LWF Application Config file
-- 
--
return {
	config={
		templates="templates",
	},

	debug={
		on=true,
		to="response", -- "ngx.log"
	},

	subapps={
		--demo3 = {path="/path/to/subapp", config={}},
	},
}
