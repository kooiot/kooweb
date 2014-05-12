return {
	get = function(req, res)
		if not lwf.ctx.user then
			res:redirect('/user/login')
		end
		res:ltp('user/profile.html')
	end,
	post = function(req, res)
		req:read_body()
		if lwf.ctx.user then
			local file = req.post_args['file']
			local file_path = app.config.static..'upload/avatar/'
			os.execute('mkdir -p '..file_path)
			local filename = file_path..lwf.ctx.user.username..'.jpg'
			local f, err = io.open(filename, 'w+')
			if f then
				f:write(file.contents)
				f:close()
			end
			res:ltp('user/profile.html', {lwf=lwf, app=app, info=err})
		else
			res:redirect('/user/login')
		end
	end,
}
