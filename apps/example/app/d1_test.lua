
local JSON = require 'cjson'
local logger = require 'lwf.logger'

local function hello(req, resp, name)
    if req.method=='GET' then
        -- resp:writeln('Host: ' .. req.host)
        -- resp:writeln('Hello, ' .. ngx.unescape_uri(name))
        -- resp:writeln('name, ' .. req.uri_args['name'])
        resp.headers['Content-Type'] = 'application/json'
        resp:write(JSON.encode(req.uri_args))
    elseif req.method=='POST' then
        -- resp:writeln('POST to Host: ' .. req.host)
        req:read_body()
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.post_args))
    end 
end


local function ltp(req,resp,...)
    logger:debug("ltp")
    resp:defer(function(n)
                   for i = 1, n do
                       logger:debug("num in defer: " .. tostring(i))
                       ngx.sleep(1)
                   end
               end, 100)
    resp:ltp('d1_ltp.html',{v=111})
    logger:debug("response will be finished after this log")
end

return {
	hello = hello,
	ltp = ltp,
}

