PATH=/usr/local/openresty/nginx/sbin:$PATH
export PATH

TMP_DIR=/tmp/kooweb_tmp

if [ ! -d $TMP_DIR ] ; then
	mkdir $TMP_DIR
fi

mkdir -p $TMP_DIR/logs

PAR=$1
if [ $# != 1 ] ; then
	PAR="start"
fi

if [ $PAR = "stop" ] ; then
	echo "Stoping nginx...."
	nginx -p $TMP_DIR/ -c `pwd`/conf/nginx.conf -s stop
else
	echo "Starting nginx...."
	nginx -p $TMP_DIR/ -c `pwd`/conf/nginx.conf
fi

