local _M = {}
_M.err = {}

_M.err[404] = [[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL was not found on this server.<P>
</BODY></HTML>]]

_M.err[403] = [[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>403 Forbidden</TITLE>
</HEAD><BODY>
<H1>Forbidden</H1>
You are not allowed to access the requested URL.<P>
</BODY></HTML>]]

_M.err[405] = [[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>405 Method Not Allowed</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The Method is not allowed for URL on this server.<P>
</BODY></HTML>]]

return _M
