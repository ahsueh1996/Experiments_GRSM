pd=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate

td=/home/CMC/spark/assembly/target/scala-2.11/jars

cd $pd
yes 'yes' | cp archive/hacks/conglomerate/* . -r

cd $td
sh $pd/hack.sh mllib/optimization spark-mllib_2.11-2.1.0.jar

cd $pd
sh run.sh conglomerate standalone no_jmh
sh run.sh conglomerate local no_jmh

cd $td
sh $pd/unhack.sh mllib/optimization spark-mllib_2.11-2.1.0.jar

