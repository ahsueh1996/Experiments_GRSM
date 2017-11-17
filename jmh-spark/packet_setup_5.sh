#!/bin/bash
########################################################HEADER######################################################
# General Settings:
# Where Hadoop, Spark, etc is built and stored
WORK_DIR=/CMC/kmiecseb
# Is this in fact an ARM machine (not an x86)					
ARM_MACHINE=${IS_ARM}
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

########################################################PART 5######################################################
### Search for hibench in workdir ###
cd $WORK_DIR

# Grab HiBench...
#
#if [  ! -d "HiBench"  ];then
if [  -d "HiBench"  ];then
		
	# Grab and build HiBench 6.0:	
	cd $WORK_DIR
# 	git clone https://github.com/intel-hadoop/HiBench.git
	cd HiBench
# 	mvn -Dspark=2.1 -Dscala=2.11 clean package

	# Configure HiBench:
# 	cp conf/hadoop.conf.template conf/hadoop.conf
# 	cp conf/spark.conf.template conf/spark.conf
	
	# Configure HadoopBench:
	sed -i "s#.*/PATH/TO/YOUR/HADOOP/ROOT.*#hibench.hadoop.home    $WORK_DIR/hadoop#g" conf/hadoop.conf
	sed -i "s#.*hibench.hdfs.master.*#hibench.hdfs.master    hdfs://localhost:9000#g" conf/hadoop.conf

	# Configure SparkBench:
	sed -i "s#.*hibench.spark.home.*#hibench.spark.home    $WORK_DIR/spark#g" conf/spark.conf

	if [ "$USE_YARN_FOR_SPARK_ON_HADOOP" = true ] ; then
		sed -i "s#.*hibench.spark.master.*#hibench.spark.master    yarn-client#g" conf/spark.conf
	else
		LOCAL_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
		sed -i "s#.*hibench.spark.master.*#hibench.spark.master    spark://$LOCAL_IP:7077#g" conf/spark.conf
	fi
		

	# Advanced configurations for Spark:
	sed -i "s#.*hibench.yarn.executor.num.*#hibench.yarn.executor.num    $SPARK_EXECUTOR_INSTANCES#g" conf/spark.conf
	sed -i "s#.*hibench.yarn.executor.cores.*#hibench.yarn.executor.cores    $SPARK_EXECUTOR_CORES#g" conf/spark.conf
	sed -i "s#.*spark.executor.memory.*#spark.executor.memory    $SPARK_EXECUTOR_MEMORY#g" conf/spark.conf
	sed -i "s#.*spark.driver.memory.*#spark.driver.memory    $SPARK_DRIVER_MEMORY#g" conf/spark.conf

	# More general advanced configurations:
	sed -i "s#.*hibench.default.map.parallelism.*#hibench.default.map.parallelism                  $YARN_CORES#g" conf/hibench.conf
	sed -i "s#.*hibench.default.shuffle.parallelism.*#hibench.default.shuffle.parallelism              $YARN_CORES#g" conf/hibench.conf

	
	# Disable LSE
	if [ "$ARM_MACHINE" = true ] ; then
		echo "spark.executor.extraJavaOptions       -XX:-UseLSE" >> conf/spark.conf
		echo "spark.io.compression.codec      lzf" >> conf/spark.conf
		echo "spark.driver.extraJavaOptions      -XX:-UseLSE" >> conf/spark.conf
	fi
	cd $WORK_DIR/HiBench
	rm conf/spark.conf.jmhspark
	cp conf/spark.conf conf/spark.conf.jmhspark
	### do more ###
	cd $WORK_DIR
else
  echo seems that there is already HiBench
fi
