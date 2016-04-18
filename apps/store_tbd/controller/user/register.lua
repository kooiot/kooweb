return {
	get = function(req, res)
		res:ltp('user/register.html', {lwf=lwf, app=app})
	end,
	post = function(req, res)
		req:read_body()
		local username = req:get_post_arg('username')
		local password = req:get_post_arg('password')

		local r, err
		if username and password then
			local auth = lwf.ctx.auth
			r, err = auth:has(username)
			if r then
				err = 'User existed, please pickup another name'
			else
				r, err = auth:add_user(username, password)
			end
		else
			err = 'Incorrect Post Message!!'
		end
		res:ltp('user/login.html', {app=app, lwf=lwf, err=err})
	end,
}
