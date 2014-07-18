-----------------------------------------------
-----------------------------------------------

map('^/app/detail/(.*)', 'app/detail')
map('^/app/modify/(.*)', 'app/modify')
map('^/devices/(.*)', 'device/detail')
map('^/data/(.*)', 'device/data')
map('^/dumpdata/(.*)', 'device/dumpdata')
map('^/device/ctrl/(.*)', 'device/remote')
map('^/users/(.*)', 'user/detail')
