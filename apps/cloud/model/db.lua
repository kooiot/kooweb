local mysql = require 'resty.mysql'
local logger = require 'lwf.logger'
local cjson = require 'cjson'

local _M = {}
local class = {}

_M.new = function(m)
	local obj = {
		lwf = m.lwf,
		app = m.app,
		con = con
	}

	return setmetatable(obj, {__index=class})	
end

function class:init()
	if self.con then 
		return true
	end

	local con = mysql:new()
	con:set_timeout(500)
	local ccfg = {
		database='kooweb',
		host='127.0.0.1',
		port=3306,
		user='root',
		password='19840310'
	}
	local ok, err = con:connect(ccfg)
	if not ok then
		print(err)
		logger:error(err)
		return nil
	end
	self.con = con
	return true
end

function class:close()
	self.con:close()
	self.con = nil
end

function class:list_apps(username)
	assert(username)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local sql = "select * from gapps where owner='"..username.."'"
	local r, err = con:query(sql)
	if r then
		local apps = {}
		for k, v in pairs(r) do
			apps[k] = {name=r.name, info=r}
		end
		return apps
	else
		return nil, err
	end
end

function class:list_all()
	local apps = {}
	local con = self.con
	if con then
		local sql = 'select * from apps order by votes limit 50'
		local r, err = con:query(sql)
		if r then
			apps = r
		end
	end
	return apps
end

function class:get_app(username, appname)
	assert(appname)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local sql = "select * from apps where owner='"..username.."'and name='"..appname.."'"
	local r, err = con:query(sql)

	if r then
		return r[1]
	else
		return nil, err
	end
end

function class:create_app(info)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local fmt = "insert into apps (name, owner, desc, version, votes, comments) values ('%s', '%s', '%s', '%s', %f, '%s'"
	local res, err = con:query(string.format(fmt, info.name, info.owner, info.desc, info.version, info.votes, info.comments))

	print(res.affected_rows, " rows inserted into table cats ", "(last insert id: ", res.insert_id, ")")
	return res, err
end

function class:delete_app(username, appname)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local fmt = "delete from apps where name='%s' and owner='%s'"
	return con:query(string.format(fmt, appname, username))
end

function class:delete_app_by_id(id)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local fmt = "delete from apps where id=%d"
	return con:query(string.format(fmt, id))
end

function class:update_app(info)
	local con = self.con
	if not con then
		return nil, 'Database connection is not initialized'
	end

	local fmt = "update apps set name='%s', owner='%s', desc='%s', version='%s', votes=%f, comments='%s' where id=%d"
	return con:query(string.format(fmt, info.name, info.owner, info.desc, info.version, info.votes, info.comments, info.id))
end

function class:check_user_key(key)
	local con = self.con
	if con then
		local r, err = con:get('userkey.key.'..key)
		if r == ngx.null then
			return nil, 'User authkey is no exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:get_user_key(username)
	local con = self.con
	if con then
		local r, err = con:get('userkey.user.'..username)
		if r == ngx.null then
			return nil, 'No exists'
		else
			return r, err
		end
	else
		return nil, 'Database connection is not initialized'
	end
end

function class:set_user_key(username, key)
	local con = self.con
	if con then
		local uname = self:check_user_key(key)
		if uname and uname ~= username then
			return nil, 'The auth key has been used by other user'..uname
		end

		local r, err = con:set('userkey.key.'..key, username)
		if not r then
			return nil, err
		end
		r, err = con:set('userkey.user.'..username, key)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

function class:del_tpl(app_path, tpl_path)
	local con = self.con
	if con then
		local r, err = con:del('tpl.of.'..app_path..'/'..tpl_path)
		r, err = con:srem('tpl.set.of.'..app_path, tpl_path)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

function class:add_tpl(app_path, tpl, force)
	local con = self.con
	if con then
		local cjson = require 'cjson'
		local r, err = con:set('tpl.of.'..app_path..'/'..tpl.path, cjson.encode(tpl))
		if not r then
			return err
		end

		r, err = con:sadd('tpl.set.of.'..app_path, tpl.path)
		return r, err
	end
	return nil, 'Database connection is not initialized'
end

function class:update_tpl(app_path, tpl)
	return self:add_tpl(app_path, tpl, true)
end

function class:get_tpl(app_path, tpl_path)
	local con = self.con
	if con then
		local cjson = require 'cjson'
		local r, err = con:get('tpl.of.'..app_path..'/'..tpl_path)
		if not r then
			return nil, err
		end
		return cjson.decode(r)
	end
	return nil, 'Database connection is not initialized'
end

function class:list_tpl(app_path)
	local con = self.con
	if con then
		local r, err = con:smembers('tpl.set.of.'..app_path)
		if not r then
			return nil, err
		end

		if r == ngx.null then
			r = {}
		end

		return r
	end
	return nil, 'Database connection is not initialized'
end

return _M
