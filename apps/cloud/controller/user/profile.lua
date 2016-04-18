return {
	get = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end
		local db = app.model:get('db')
		db:init()
		local username = lwf.ctx.user.username
		local cur_key = db:get_user_key(username)
		res:ltp('user/profile.html', {lwf=lwf, app=app, userkey=cur_key, info=err})
	end,
	post = function(req, res)
		req:read_body()
		if lwf.ctx.user then
			local db = app.model:get('db')
			local auth = lwf.ctx.auth
			db:init()
			local username = lwf.ctx.user.username
			local cur_key = db:get_user_key(username)

			local action = req.post_args['action']
			if action == 'avatar' then
				local file = req.post_args['file']
				local file_path = app.config.static..'upload/avatar/'
				os.execute('mkdir -p '..file_path)
				local filename = file_path..username..'.jpg'
				local f, err = io.open(filename, 'w+')
				if f then
					f:write(file.contents)
					f:close()
				end
				res:ltp('user/profile.html', {lwf=lwf, app=app, userkey=cur_key, info=err})
			elseif action == 'passwd' then
				local orgpass = req:get_arg('org_pass')
				local newpass = req:get_arg('new_pass')
				local newpass2 = req:get_arg('new_pass2')
				local err = nil
				if newpass ~= newpass2 then
					err = 'Password re-type is not same'
				else
					local r = auth:authenticate(tostring(username), tostring(orgpass))
					if not r then
						err = 'Original password failure'
					else
						r, err = auth:set_password(tostring(username), tostring(newpass))
					end
				end
				res:ltp('user/profile.html', {lwf=lwf, app=app, userkey=cur_key, info=err})
			elseif action == 'userkey' then
				local key = req:get_arg('key')
				local err = nil
				if not key then
					err = 'No key in post request'
				else
					local db = app.model:get('db')
					db:init()

					local r, e =  db:set_user_key(username, key)
					if not r then
						err = e
					else
						cur_key = key
					end
				end
				res:ltp('user/profile.html', {lwf=lwf, app=app, userkey=cur_key, info=err})
			end
		else
			res:redirect('/user/login')
		end
	end,
}
