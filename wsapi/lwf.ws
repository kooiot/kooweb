
local m_path = os.getenv('LWF_ROOT') or "../lwf"
local m_package_path = package.path  
package.path = string.format("./?/init.lua;%s;%s/?.lua;%s/?/init.lua", m_package_path, m_path, m_path)  

local app = require('wsapi_app')
local run = app.new({
	BASE_URL        = '/',
	PASSWORD_SALT   = '8C7f8lProgw3U4IvVyDqk38bD0HAD8hBBfHZRMRF',
	TOKEN_SALT      = 'tdzd77zTw3aHW8IqZgQteXUG3s5kFMQZQf2ODSXZ',
	USE_POSIX_CRYPT = true,
	SHOW_STACK_TRACE = true,
})

return {
	run = run
}
