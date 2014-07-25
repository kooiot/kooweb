local function get_full_path()
	local path = app.config.static..'releases/sys'
	os.execute('mkdir -p '..path)
	return path
end

local function save_file(filename, file)
	local path = get_full_path()
	local filename = path..'/'..filename
	local vfilename = path..'/cad2_xz.latest.sfs'
	local f, err = io.open(filename, 'w+')
	if f then
		f:write(file.contents)
		f:close()
		os.execute('cp '..filename..' '..vfilename)
		return true
	end
	return nil, err
end


return {
	get = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end
		local db = app.model:get('sys')
		db:init()
		local list, err = db:list()
		db:close()
		res:ltp('/sys/new.html', {lwf=lwf,app=app,list=list})
	end,
	post = function(req, res)
		if not lwf.ctx.user then
			return res:redirect('/user/login')
		end
		req:read_body()

		local file = req.post_args['file']

		if file and type(file) == 'table' and next(file) then
			local name = string.match(file.filename, "([^:/\\]+)$")
			if not name then
				res:write("Error, filename is not recognized")
				return lwf.set_status(403)
			end

			local version = string.match(name, "%.(%d+)%.sfs$")
			if not version then
				res:write("Error, filename does not contains the version information"..name)
				return lwf.set_status(403)
			end

			local r, err = save_file(name, file)
			if r then
				local db = app.model:get('sys')
				db:init()
				db:push(version)
				db:close()
				res:write('<br> Upload finished!')
			else
				res:write("<br> Failed to save file, error:"..err)
			end
		else
			res:write("<br> Please select a local file first")
		end
	end
}
