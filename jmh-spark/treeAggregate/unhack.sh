# $1 relative path after org/apache/spark/ (don't include starting or ending /)
# $2 path to the jar to update with the hack. a copy of the old one will be made to the same location as the target
if [ "$1" = "" ] ; then
	echo path to target jar is missing
	exit
fi

PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
TAR_DIR=$PWD/$1

echo targeting:
echo $TAR_DIR
read -p "confirm or abort: "

yes 'yes' | cp $TAR_DIR.old $TAR_DIR && yes 'yes' | rm $TAR_DIR.old
echo done
