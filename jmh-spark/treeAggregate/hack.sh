# $1 = the alias
# $2 relative path after org/apache/spark/ (don't include starting or ending /)
# assumes that you have don't mvn package to populate target/lib
# assumes that you have copied the correct benchmarks.jar into .target as the base jar to alter

if [ "$1" = "" ] ; then
	echo alias is empty
	exit
fi
if [ "$2" = "" ] ; then
	echo rel path after org/apache/spark/ is empty
	exit
fi

PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
TAR_DIR=$PROJ_DIR/results/packet2a/optimizations/jars

cd $PROJ_DIR

yes 'yes' | rm -R "#hack_lib"
mkdir "#hack_lib"

yes 'yes' | cp $TAR_DIR/benchmarks.jar $TAR_DIR/benchmarks-${1}.jar

echo scalac-ing
scalac -classpath "target/lib/*" -d "#hack_lib/" \#hack_src/org/apache/spark/$2/*

echo updating jar
cd \#hack_lib/
jar uf $TAR_DIR/benchmarks-${1}.jar org/apache/spark/$2/*


