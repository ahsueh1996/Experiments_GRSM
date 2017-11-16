#!/bin/bash
########################################################HEADER######################################################
# General Settings:
# Where Hadoop, Spark, etc is built and stored
WORK_DIR=/CMC/kmiecseb
# Is this in fact an ARM machine (not an x86)					
ARM_MACHINE=true
# true: use YARN, false: use Spark's standalone resource manager						 
USE_YARN_FOR_SPARK_ON_HADOOP=false		

# Hadoop-YARN settings:
# Number of cores to use for Hadoop and Spark on Hadoop jobs (if using YARN).
YARN_CORES=92			
# Amount of memory to use for Hadoop and Spark on Hadoop jobs (if using YARN).				
YARN_MEM=112640						

# Spark settings:
SPARK_EXECUTOR_CORES=10
SPARK_EXECUTOR_MEMORY=10G
SPARK_DRIVER_MEMORY=10G
SPARK_WORKER_CORES=92
SPARK_WORKER_MEMORY=100g
SPARK_WORKER_INSTANCES=1
SPARK_EXECUTOR_INSTANCES=9
SPARK_DAEMON_MEMORY=2g

########################################################PART 4######################################################
### search for spark in workdir ###
cd $WORK_DIR

# Grab Spark...
#
#if [ ! -d "spark"  ];then
if [  -d "spark"  ];then
	
	# Grab and build Spark 2.1.0
	cd $WORK_DIR
# 	wget https://github.com/apache/spark/archive/v2.1.0.tar.gz
# 	tar -xf v2.1.0.tar.gz
# 	mv spark-2.1.0 spark
# 	cd spark
# 	./build/mvn -T 1C -e -Dhadoop.version=2.7.1 -DskipTests clean package	
# 	rm -f ../v2.1.0.tar.gz


	# Update SPARK path variables:
	sed -i '/SPARK_HOME/d' ~/.bashrc
	echo "export SPARK_HOME=$WORK_DIR/spark" >> ~/.bashrc
	echo "export PATH=\$PATH:\$SPARK_HOME/bin" >> ~/.bashrc
	source ~/.bashrc

	# Setup configuration files:
	cd $SPARK_HOME/conf
	cp spark-env.sh.template spark-env.sh
	cp spark-defaults.conf.template spark-defaults.conf
	cp slaves.template slaves

	# Add Spark MASTER IP:
	LOCAL_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
	sed -i "s/.*SPARK_MASTER_HOST.*/SPARK_MASTER_HOST=$LOCAL_IP/g" spark-env.sh
	sed -i "s#.*spark.master.*#spark.master spark://$LOCAL_IP:7077#g" spark-defaults.conf
	echo "spark.local.dir                    $WORK_DIR/hadoop_file/tmp" >> spark-defaults.conf
	sed -i "/SPARK_EXECUTOR_CORES/aSPARK_EXECUTOR_CORES=$SPARK_EXECUTOR_CORES" spark-env.sh
	sed -i "/SPARK_EXECUTOR_MEMORY/aSPARK_EXECUTOR_MEMORY=$SPARK_EXECUTOR_MEMORY" spark-env.sh
	sed -i "/SPARK_DRIVER_MEMORY/aSPARK_DRIVER_MEMORY=$SPARK_DRIVER_MEMORY" spark-env.sh
	sed -i "/SPARK_WORKER_CORES/aSPARK_WORKER_CORES=$SPARK_WORKER_CORES" spark-env.sh
	sed -i "/SPARK_WORKER_MEMORY/aSPARK_WORKER_MEMORY=$SPARK_WORKER_MEMORY" spark-env.sh
	sed -i "/SPARK_WORKER_INSTANCES/aSPARK_WORKER_INSTANCES=$SPARK_WORKER_INSTANCES" spark-env.sh
	sed -i "/SPARK_EXECUTOR_INSTANCES/aSPARK_EXECUTOR_INSTANCES=$SPARK_EXECUTOR_INSTANCES" spark-env.sh
	sed -i "/SPARK_DAEMON_MEMORY/aSPARK_DAEMON_MEMORY=$SPARK_DAEMON_MEMORY" spark-env.sh

	if [ "$ARM_MACHINE" = true ] ; then
		sed -i "/SPARK_DAEMON_JAVA_OPTS/aSPARK_DAEMON_JAVA_OPTS=\"-XX:-UseLSE\"" spark-env.sh
		sed -i "/spark.executor.extraJavaOptions/aspark.executor.extraJavaOptions       -XX:-UseLSE" spark-defaults.conf
		sed -i '/compression/d' spark-defaults.conf
		echo "spark.io.compression.codec      lzf" >> spark-defaults.conf
		echo "spark.driver.extraJavaOptions      -XX:-UseLSE" >> spark-defaults.conf
	fi
	
	cd $WORK_DIR
else
  echo seems that spark has already been grabbed
fi
