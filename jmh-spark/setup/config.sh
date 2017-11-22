WORK_DIR=/CMC/kmiecseb

echo -e "\e[95m======================="
echo "Current settings, abort if wrong."
echo -e "==========================\e[39m"

echo ARM_MACHINE=${IS_ARM}
echo YARN_CORES=${MY_YARN_CORES}
echo YARN_MEM=${MY_YARN_MEM}	
echo USE_YARN_FOR_SPARK_ON_HADOOP=${MY_USE_YARN_FOR_SPARK_ON_HADOOP}
echo SPARK_EXECUTOR_CORES=${MY_SPARK_EXECUTOR_CORES}
echo SPARK_EXECUTOR_MEMORY=${MY_SPARK_EXECUTOR_MEMORY}
echo SPARK_DRIVER_MEMORY=${MY_SPARK_DRIVER_MEMORY}
echo SPARK_WORKER_CORES=${MY_SPARK_WORKER_CORES}
echo SPARK_WORKER_MEMORY=${MY_SPARK_WORKER_MEMORY}
echo SPARK_WORKER_INSTANCES=${MY_SPARK_WORKER_INSTANCES}
echo SPARK_EXECUTOR_INSTANCES=${MY_SPARK_EXECUTOR_INSTANCES}
echo SPARK_DAEMON_MEMORY=${MY_SPARK_DAEMON_MEMORY}
echo SPARK_DEFAULT_PARALLELISM=${MY_SPARK_DEFAULT_PARALLELISM}
echo SPARK_SQL_SHUFFLE_PARTITIONS=${MY_SPARK_SQL_SHUFFLE_PARTITIONS}
echo
read -p "Enter to continue: "

echo -e "\e[95m==================================="
echo "Resetting relavent configs"
echo -e "======================================\e[97m"

################################################################### Hadoop...
# Hadoop configuration files (namenode, datanode, yarn):
cd $WORK_DIR/hadoop/etc/hadoop

# ALTER these properties in the configuration file 'yarn-site.xml":
sed -i "/<name>yarn.nodemanager.resource.memory-mb<\/name>/!b;n;c<value>$YARN_MEM</value>" yarn-site.xml
sed -i "/<name>yarn.nodemanager.resource.cpu-vcores<\/name>/!b;n;c<value>$YARN_CORES</value>" yarn-site.xml

##################################################################### Spark...
cd $WORK_DIR/spark
yes 'yes' | cp spark-env.sh.template spark-env.sh
yes 'yes' | cp spark-defaults.conf.template spark-defaults.conf
yes 'yes ' | cp slaves.template slaves

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

############################################################## HiBench...
cd $WORK_DIR/HiBench
yes 'yes' | cp conf/hadoop.conf.template conf/hadoop.conf
yes 'yes' | cp conf/spark.conf.template conf/spark.conf
	
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
