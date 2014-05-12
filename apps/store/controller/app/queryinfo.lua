return {
	get = function(req, res)
		local info = {
			author = 'admin',
			name = "modbus",
			['type'] = 'app.io',
			desc = "test dddd",
			comments = [[
			<div class="comment">
			<div class="content">
			<a class="author">Dog Doggington</a>
			<div class="metadata">
			<span class="date">2 days ago</span>
			</div>
			<div class="text">
			I think this is a great app and i am voting on it
			</div>
			<div class="actions">
			</div>
			</div>
			</div>
			<div class="comment">
			<div class="content">
			<a class="author">Pawfin Dog</a>
			<div class="metadata">
			<span class="date">2 days ago</span>
			</div>
			<div class="text">
			I think this is a great app and i am voting on it
			</div>
			<div class="actions">
			</div>
			</div>
			</div>
			<div class="comment">
			<div class="content">
			<a class="author">Dog Doggington</a>
			<div class="metadata">
			<span class="date">2 days ago</span>
			</div>
			<div class="text">
			I think this is a great app and i am voting on it
			</div>
			<div class="actions">
			</div>
			</div>
			</div>
			]]
		}
		local cjson = require 'cjson'
		res.headers['Content-Type'] = 'application/json; charset=utf-8'

		local callback = req:get_arg('callback')
		if not callback then
			res:write(cjson.encode(info))
		else
			res:write(callback)
			res:write('(')
			res:write(cjson.encode(info))
			res:write(')')
		end
	end
}
