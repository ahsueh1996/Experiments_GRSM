# $1 relative path after org/apache/spark/ (don't include starting or ending /)
# $2 path to the jar to update with the hack. a copy of the old one will be made to the same location as the target
if [ "$2" = "" ] ; then
	echo path to target jar is missing
	exit
fi
if [ "$1" = "" ] ; then
	echo rel path after org/apache/spark/ is empty
	exit
fi

PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
TAR_DIR=$PWD/$2
NAME_DIR=$PWD/$3

echo targeting:
echo $TAR_DIR
read -p "confirm or abort: "

cd $PROJ_DIR

yes 'yes' | rm -R "#hack_lib"
mkdir "#hack_lib"

if [ -f ${TAR_DIR}.old ] ; then
	read -p ".old found, rehacking instead, pls confirm or abort: "
	yes 'yes' | cp ${TAR_DIR}.old $TAR_DIR
else
	yes 'yes' | cp $TAR_DIR ${TAR_DIR}.old
fi

echo scalac-ing
scalac -classpath "target/lib/*" -d "#hack_lib/" \#hack_src/org/apache/spark/$1/*

echo updating jar
cd \#hack_lib/
jar uf $TAR_DIR org/apache/spark/$1/*

if [ "$3" != "" ] ; then
	yes 'yes' | cp $TAR_DIR $NAME_DIR
fi

echo done, remember to unhack using the target directory you supplied
