if [ "$1" = "" ] ; then
	delay=5
else
	delay=$1
fi

while true ; do
	echo "collecting..."
	echo 
	df | grep " /" | grep -v " /*"
	sleep $delay
done
