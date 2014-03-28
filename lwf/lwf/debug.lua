
local _M = {}

local DEBUG_INFO_CSS=[==[
            <style rel="stylesheet" type="text/css">
            #lwf-table-of-contents {
                font-size: 9pt;
                position: fixed;
                right: 0em;
                top: 0em;
                background: white;
                -webkit-box-shadow: 0 0 1em #777777;
                -moz-box-shadow: 0 0 1em #777777;
                box-shadow: 0 0 1em #777777;
                -webkit-border-bottom-left-radius: 5px;
                -moz-border-radius-bottomleft: 5px;
                border-radius-bottomleft: 5px;
                text-align: right;
                /* ensure doesn't flow off the screen when expanded */
                max-height: 80%;
                overflow: auto; 
                z-index: 200;
            }
            #lwf-table-of-contents h2 {
                font-size: 10pt;
                max-width: 8em;
                font-weight: normal;
                padding-left: 0.5em;
                padding-top: 0.05em;
                padding-bottom: 0.05em; 
            }

            #lwf-table-of-contents ul {
                margin-left: 14pt; 
                margin-bottom: 10pt;
                padding: 0
            }

            #lwf-table-of-contents li {
                padding: 0;
                margin: 1px;
                list-style: none;
            }

            #lwf-table-of-contents #lwf-text-table-of-contents {
                display: none;
                text-align: left;
            }

            #lwf-table-of-contents:hover #lwf-text-table-of-contents {
                display: block;
                padding: 0.5em;
                margin-top: -1.5em; 
            }
            </style>
        ]==]

function _M.traceback ()
    for level = 1, math.huge do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then   -- is a C function?
            print(level, "C function")
        else   -- a Lua function
            print(string.format("[%s]:%d", info.short_src,
                                info.currentline))
        end
    end
end

local function debug_utils()
    local debug_info={info={}}
    
    function _debug_hook(event, extra)
        local info = debug.getinfo(2)
        if info.currentline<=0 then return end
        --if (string.find(info.short_src,"lwf/luasrc") or 
        --string.find(info.short_src,"lwf/lualib")) then
        --return
        --end
        info.event=event
        table.insert(debug_info.info,info)
    end

    function _debug_clear()
        debug_info.info={} 
    end

    function _debug_info()
        return debug_info
    end
    
    return _debug_hook, _debug_clear, _debug_info
end


_M.debug_hook, _M.debug_clear, _M.debug_info = debug_utils()

function _M.debug_info2html()
    
    local ret = DEBUG_INFO_CSS .. [==[
                <div id="lwf-table-of-contents">
                <h2>DEBUG INFO </h2>
                <div id="lwf-text-table-of-contents"><ul>
        ]==]
    for _, info in ipairs(debug_info().info) do
        local estr= "unkown event"
        if info.event=="call" then
            estr = " -> "
        elseif info.event=="return" then
            estr = " <- "
        end
        local sinfo=(string.format("<li>%s [function %s] in file [%s]:%d,</li>\r\n",
                                   estr,
                                   tostring(info.name),
                                   info.short_src,
                                   info.currentline))
        ret = ret .. sinfo
    end
    return ret .. "</ul></div></div>"
end


function _M.debug_info2text()
    local ret = "DEBUG INFO:\n"
    for _, info in ipairs(debug_info().info) do
        local estr = "unkown event"
        if info.event=="call" then
            estr = " -> "
        elseif info.event=="return" then
            estr = " <- "
        end
        local sinfo=(string.format("%s [function %s] in file [%s]:%d,\n",
                                   estr,
                                   tostring(info.name),
                                   info.short_src,
                                   info.currentline))
        ret = ret .. sinfo
    end
    return ret
end

return _M
