return {
	Industrial = {
		{
			name = 'example',
			desc = 'example io application',
			version = "1.0",
			author='cch',
			manufactor = 'OpenGate',
			path='symtech/example',
			type = 'app.io',
			depends = {},
		},
		{
			name = 'Modbus',
			desc = 'Modbus io application',
			version = "1.0",
			author='cch',
			manufactor = 'OpenGate',
			type = 'app.io',
			depends = {},
			path='symtech/modbus',
		},
		{
			name = "S5500",
			desc = "旋思科技5500电表, Modbus协议",
			version = "1.1",
			author = 'dirk',
			manufactor = 'SymTech Inc.',
			type = 'app.io.config',
			depends = {'example'},
			path='symtech/s5500',
		},
	},
	Cloud = {
		{
			name = "YeeLink",
			desc = "将数据采集转发到YeeLink数据平台",
			version = "0.1",
			author = 'dirk',
			manufactor = 'SymTech Inc.',
			type = 'app',
			depends = {},
			path='symtech/yeelink',
		},
	}
}
