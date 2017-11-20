
TODO!!!!!

WORK_DIR=/CMC/kmiecseb

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

echo -e "\e[95m==================================="
echo "Resetting relavent configs"
echo -e "======================================\e[97m"

cd $WORK_DIR/HiBench
if [ "$USE_YARN_FOR_SPARK_ON_HADOOP" = true ] ; then
		sed -i "s#.*hibench.spark.master.*#hibench.spark.master    yarn-client#g" conf/spark.conf
	else
		LOCAL_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
		sed -i "s#.*hibench.spark.master.*#hibench.spark.master    spark://$LOCAL_IP:7077#g" conf/spark.conf
fi


  
  
