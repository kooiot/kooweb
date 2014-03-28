PATH=/usr/local/openresty/nginx/sbin:$PATH
export PATH

if [ ! -d tmp ] ; then
	mkdir tmp
fi

cd tmp
if [ ! -d logs ] ; then
	mkdir logs
fi

PAR=$1
if [ $# != 1 ] ; then
	PAR="start"
fi

if [ $PAR = "stop" ] ; then
	echo "Stoping nginx...."
	nginx -p `pwd`/ -c ../conf/nginx.conf -s stop
else
	echo "Starting nginx...."
	nginx -p `pwd`/ -c ../conf/nginx.conf
fi

cd ..
