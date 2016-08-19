local function add_user(auth, username, password, password_confirm, first_name, last_name)
	if password ~= password_confirm then
		return nil, "Password is not same as password confirm!"
	end
	if string.len(password) < 6 then
		return nil, "Password is too short!"
	end
	if string.len(username) < 4 then
		return nil, "Username is too short!"
	end

	local r, err = auth:has(username)
	if r then
		err = 'User existed, please pickup another name'
	else
		local meta = {
			fname = first_name,
			lname = last_name,
		}
		r, err = auth:add_user(username, password, meta)
	end
	return r, err
end
return {
	get = function(req, res)
		res:ltp('user/register.html', {lwf=lwf, app=app})
	end,
	post = function(req, res)
		local auth = lwf.ctx.auth
		req:read_body()
		local username = req:get_post_arg('username')
		local password = req:get_post_arg('password')
		local password_confirm = req:get_post_arg('password-confirm')
		local first_name = req:get_post_arg('first-name')
		local last_name = req:get_post_arg('last-name')

		local r, err
		if username and password and password_confirm then
			r, err = add_user(auth, username, password, password_confirm, first_name, last_name)
		else
			err = 'Incorrect Post Message!!'
		end
		res:ltp('user/register.html', {app=app, lwf=lwf, info=err})
	end,
}
