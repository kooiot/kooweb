-- Authentification module (by using resty.mysql)
--

local logger = require 'lwf.logger'
local sql = require 'resty.mysql'
local cjson = require 'cjson'
local md5 = require 'md5'

local _M = {}
local class = {}

_M.new = function(lwf, app)
	local obj = {
		lwf = lwf,
		app = app,
		conn = conn,
	}

	return setmetatable(obj, {__index=class})
end

local quote = ngx.quote_sql_str

function class:attach()
	--logger:debug('[MYSQL] Connection Attach!!!!!!!!!!!!!!!!!!!!!!!')
	local conn, err = assert(sql:new())
	conn:set_timeout(500)
	local ok, err = conn:connect({
		host = '127.0.0.1',
		port = 3306,
		database = 'kooweb',
		user = 'root',
		password = '19840310',
		max_packet_size = 1024 * 1024,
	})
	if not ok then
		logger:error('Authentification module [MYSQL] got Error -'..tostring(err))
	end
	self.conn = conn
end

function class:detach()
	--logger:debug('[MYSQL] Connection Detach!!!!!!!!!!!!!!!!!!!!!!!')
	self.conn:set_keepalive(10000, 100)
	self.conn = nil
end

function class:authenticate(username, password)
	local qusername = quote(username)
	local sql = 'select * from users where username='..qusername
	local res, err = self.conn:query(sql) 
	if res and #res == 1 then
		return res[1].password==password
	end

	--logger:debug('[MYSQL] authenticate: '..username..' Input:'..password..' Error:'..(err or ''))

	if not res or #res ~= 1 then
		--logger:debug('Check for admin')
		if username == 'admin' and password == 'admin' then
			return self:add_user('admin', 'admin', {})
			--return true
		end
	end
	return false, 'Incorrect username or password'
end

function class:identity(username, identity)
	local qusername = quote(username)
	local sql = 'select * from identity where username='..qusername
	local res, err = self.conn:query(sql) 
	if res and #res == 1 then
		--logger:debug('[MYSQL] identity '..dbidentity..' identity:'..identity)
		return res.identity == identity
	else
		--logger:debug('[MYSQL] identity failure ', username, ' ', identity)
		return false
	end
end

function class:get_identity(username)
	--logger:debug('[MYSQL] get_identity '..username)
	local qusername = quote(username)
	local sql = 'select * from identity where username='..qusername
	local res, err = self.conn:query(sql) 
	if res and #res == 1 then
		--logger:debug('[MYSQL] identity from db result'..res.identity)
		return res.identity
	else
		local identity = md5.sumhexa(username..os.date())
		local sql = 'insert into identity (id, identity) values ('..username..', '..identity..')'
		--logger:debug('[MYSQL] new identity result'..identity)
		return identity
	end
end

function class:clear_identity(username)
	local username = quote(username)
	self.conn:query('delete from identity where username='..username)
	return true
end

function class:set_password(username, password)
	local username = quote(username)
	local password = quote(password)
	local r, err = self.conn:query('update users SET password='..password..' where username='..username)
	return r, err
end

function class:add_user(username, password, mt)
	local username = quote(username)
	local password = quote(password)
	local mt = quote(cjson.encode(mt))
	local sql = "insert into users (username, password, meta) values ("..username..", "..password..", "..mt..")"
	local r, err = self.conn:query(sql)
	return r, err
end

function class:get_metadata(username, key)
	local username = quote(username)
	local sql = 'select * from users where username='..username
	local res, err = self.conn:query(sql) 
	if res and #res == 1 then
		return cjson.decode(res.meta)
	end

	return nil, err
end

function class:has(username)
	local username = quote(username)
	local sql = 'select * from users where username='..username
	local res, err = self.conn:query(sql) 
	logger:debug('[MYSQL] add user to db result:', res, err)
	return not res or #res == 0
end

return _M