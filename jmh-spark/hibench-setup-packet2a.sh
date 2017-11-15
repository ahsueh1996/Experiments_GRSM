#!/bin/bash

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



###### I installed the "Development Tools" on previous to this; seems necessary to get rid of some gcc errors #######
# Basic dependecies needed:
yum -y install gcc glibc-headers git autoconf automake libtool gcc-c++ cmake vim zlib-devel openssl-devel svn cpan libssh2-devel iptables-services tree bzip2 perl-devel perf sysstat 


#
# Get a JDK for ARM
#
cd $WORK_DIR
wget http://openjdk.linaro.org/releases/jdk8u-server-release-1708.tar.xz
tar -xf jdk8u-server-release-1708.tar.xz
rm -f jdk8u-server-release-1708.tar.xz
echo "export JAVA_HOME=$WORK_DIR/jdk8u-server-release-1708"  >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin"  >> ~/.bashrc
source ~/.bashrc

# Grab Maven
cd $WORK_DIR
cd /opt
wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
sudo tar xzf apache-maven-3.3.9-bin.tar.gz
sudo ln -s apache-maven-3.3.9 maven

#
# Apache Maven
#
echo "export M2_HOME=/opt/maven" >> ~/.bashrc
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> ~/.bashrc
###### no file maven.sh found at the specified location... what? #####
touch /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
###### added another soucre cmd, not sure if we will need it ####
source ~/.bashrc


### Grab Protobuf #####
###
if ! type protoc > /dev/null; then
	cd $WORK_DIR
	wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
	tar -xf protobuf-2.5.0.tar.gz
	rm -f protobuf-2.5.0.tar.gz
	cd protobuf-2.5.0

	# The header files of protobuf currently do no support ARM, these patches below correct these header files:
	if [ "$ARM_MACHINE" = true ] ; then
		wget https://gist.githubusercontent.com/BennettSmith/7111094/raw/40085b5022b5bc4d5656a9906aee30fa62414b06/0001-Add-generic-gcc-header-to-Makefile.am.patch
		wget https://gist.githubusercontent.com/BennettSmith/7111094/raw/40085b5022b5bc4d5656a9906aee30fa62414b06/0001-Add-generic-GCC-support-for-atomic-operations.patch
		git apply --verbose 0001-Add-generic-gcc-header-to-Makefile.am.patch
		git apply --verbose 0001-Add-generic-GCC-support-for-atomic-operations.patch
	fi

	# Configure and build
	./configure
	make
	make check
	make install
	cd $WORK_DIR
	rm -rf protobuf-2.5.0/
fi




# Grab Hadoop...
#
if [  ! -d "hadoop"  ];then

 	printf "\nGrabbing and preparing Hadoop 2.7.1...\n"

 	# Grab and build Hadoop 2.7.1:
	cd $WORK_DIR
	wget https://github.com/apache/hadoop/archive/release-2.7.1.tar.gz
	tar -xf release-2.7.1.tar.gz
	cd hadoop-release-2.7.1
	mvn clean package -Pdist -DskipTests
	mkdir ../hadoop
	cp -R hadoop-dist/target/hadoop-2.7.1 ../hadoop/
	cd ..
	rm -rf hadoop-release-2.7.1 release-2.7.1.tar.gz

	# Remove lines containing YARN/HADOOP
	sed -i '/YARN/d' ~/.bashrc 
	sed -i '/HADOOP/d' ~/.bashrc 
	sed -i '/LD_LIBRARY/d' ~/.bashrc

	# Update HADOOP path variables:
	echo "export HADOOP_HOME=$WORK_DIR/hadoop" >> ~/.bashrc
	echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=/usr/local/lib" >> ~/.bashrc
	echo "export YARN_HOME=$WORK_DIR/hadoop"  >> ~/.bashrc
 	echo "export HADOOP_HDFS_HOME=$WORK_DIR/hadoop"  >> ~/.bashrc
	source ~/.bashrc

	# 
	# Hadoop configuration files (namenode, datanode, yarn):
	#
	cd $HADOOP_HOME/etc/hadoop
	sed -i "s#.*export JAVA_HOME.*#export JAVA_HOME=$JAVA_HOME#g" hadoop-env.sh

	# Disable LSE instructions for spawned JVMs:
	if [ "$ARM_MACHINE" = true ] ; then
 		sed -i "s#.*export HADOOP_OPTS.*#export HADOOP_OPTS=\"\$HADOOP_OPTS -XX:-UseLSE -Djava.net.preferIPv4Stack=true\"#g" hadoop-env.sh
		sed -i "/unset IFS/aYARN_OPTS=\"\$YARN_OPTS -XX:-UseLSE\"" yarn-env.sh
	fi
	# Client needs larger heap size for complex jobs (Bayes, ALS, ...)
	sed -i "s#.*HADOOP_CLIENT_OPTS.*#export HADOOP_CLIENT_OPTS=\"-Xmx4096m \$HADOOP_CLIENT_OPTS\"#g" hadoop-env.sh


	# Add these properties in the configuration file 'core-site.xml":
	sed -i "/<configuration>/a<property>\n\
		<name>fs.default.name</name>\n\
		<value>hdfs://localhost:9000</value>\n\
		</property>\n\
		<property>\n\
		<name>hadoop.tmp.dir</name>\n\
		<value>$WORK_DIR/hadoop_file/tmp</value>\n\
		</property>" core-site.xml

	# Add these properties in the configuration file 'hdfs-site.xml":
	sed -i "/<configuration>/a<property>\n\
		<name>dfs.name.dir</name>\n\
		<value>$WORK_DIR/hadoop_file/name</value>\n\
		</property>\n\
		<property>\n\
		<name>dfs.data.dir</name>\n\
		<value>$WORK_DIR/hadoop_file/data</value>\n\
		</property>\n\
		<property>\n\
		<name>dfs.replication</name>\n\
		<value>1</value>\n\
		</property>" hdfs-site.xml

	# Add these properties in the configuration file 'yarn-site.xml":
	sed -i "/<configuration>/a<property>\n\
		<name>yarn.resoucemanager.address</name>\n\
		<value>localhost:8032</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.resourcemanager.hostname</name>\n\
		<value>localhost</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.resourcemanager.scheduler.address</name>\n\
		<value>localhost:8030</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.resourcemanager.resource-tracker.address</name>\n\
		<value>localhost:8031</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.resourcemanager.admin.address</name>\n\
		<value>localhost:8033</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.nodemanager.aux-services</name>\n\
		<value>mapreduce_shuffle</value>\n\
		</property>\n\
		<property>\n\
		<name>yarn.scheduler.minimum-allocation-mb</name>\n\
		<value>256</value>\n\
		<description>Minimum limit of memory to allocate to each container request at the Resource Manager.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.scheduler.maximum-allocation-mb</name>\n\
		<value>4096</value>\n\
		<description>Maximum limit of memory to allocate to each container request at the Resource Manager.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.scheduler.minimum-allocation-vcores</name>\n\
		<value>1</value>\n\
		<description>The minimum allocation for every container request at the RM,\n\
			 in terms of virtual CPU cores. Requests lower than this won't take effect, and the specified value will get allocated the minimum.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.scheduler.maximum-allocation-vcores</name>\n\
		<value>4</value>\n\
		<description>The maximum allocation for every container request at the RM, in terms of virtual CPU cores.\n\
			 Requests higher than this won't take effect, and will get capped to this value.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.nodemanager.resource.memory-mb</name>\n\
		<value>$YARN_MEM</value>\n\
		<description>Physical memory, in MB, to be made available to running containers</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.nodemanager.resource.cpu-vcores</name>\n\
		<value>$YARN_CORES</value>\n\
		<description>Number of CPU cores that can be allocated for containers.</description>\n\
		</property>" yarn-site.xml


	# Add these properties in the configuration file 'mapred-site.xml":	
	cp mapred-site.xml.template mapred-site.xml

	if [ "$ARM_MACHINE" = true ] ; then
		sed -i "/<configuration>/a<property>\n\
		<name>yarn.app.mapreduce.am.command-opts</name>\n\
		<value>-Xmx1536m -XX:-UseLSE</value>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.java.opts</name><value>-Xmx1536m -XX:-UseLSE</value>\n\
		<description>Heap-size for child jvms of reduces.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.java.opts</name><value>-Xmx1536m -XX:-UseLSE</value>\n\
		<description>Heap-size for child jvms of maps.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.app.mapreduce.am.resource.mb</name>\n\
		<value>2048</value>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.framework.name</name>\n\
		<value>yarn</value>\n\
		<description>Execution framework.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.cpu.vcores</name>\n\
		<value>1</value>\n\
		<description>The number of virtual cores required for each map task.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.cpu.vcores</name>\n\
		<value>1</value>\n\
		<description>The number of virtual cores required for each map task.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.memory.mb</name>\n\
		<value>2048</value>\n\
		<description>Larger resource limit for maps.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.memory.mb</name>\n\
		<value>2048</value>\n\
		<description>Larger resource limit for reduces.</description>\n\
		</property>" mapred-site.xml
	else
		sed -i "/<configuration>/a<property>\n\
		<name>yarn.app.mapreduce.am.command-opts</name>\n\
		<value>-Xmx1536m</value>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.java.opts</name><value>-Xmx1536m</value>\n\
		<description>Heap-size for child jvms of reduces.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.java.opts</name><value>-Xmx1536m</value>\n\
		<description>Heap-size for child jvms of maps.</description>\n\
		</property>\n\
		<property>\n\
		<name>yarn.app.mapreduce.am.resource.mb</name>\n\
		<value>2048</value>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.framework.name</name>\n\
		<value>yarn</value>\n\
		<description>Execution framework.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.cpu.vcores</name>\n\
		<value>1</value>\n\
		<description>The number of virtual cores required for each map task.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.cpu.vcores</name>\n\
		<value>1</value>\n\
		<description>The number of virtual cores required for each map task.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.map.memory.mb</name>\n\
		<value>2048</value>\n\
		<description>Larger resource limit for maps.</description>\n\
		</property>\n\
		<property>\n\
		<name>mapreduce.reduce.memory.mb</name>\n\
		<value>2048</value>\n\
		<description>Larger resource limit for reduces.</description>\n\
		</property>" mapred-site.xml
	fi

fi




# Grab Spark...
#
if [  ! -d "spark"  ];then
	
	# Grab and build Spark 2.1.0
	cd $WORK_DIR
	wget https://github.com/apache/spark/archive/v2.1.0.tar.gz
	tar -xf v2.1.0.tar.gz
	mv spark-2.1.0 spark
	cd spark
	./build/mvn -T 1C -e -Dhadoop.version=2.7.1 -DskipTests clean package	
	rm -f ../v2.1.0.tar.gz


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
fi








# Grab Hadoop...
#
if [  ! -d "HiBench"  ];then
		
	# Grab and build HiBench 6.0:	
	cd $WORK_DIR
	git clone https://github.com/intel-hadoop/HiBench.git
	cd HiBench
	mvn -Dspark=2.1 -Dscala=2.11 clean package

	# Configure HiBench:
	cp conf/hadoop.conf.template conf/hadoop.conf
	cp conf/spark.conf.template conf/spark.conf
	
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
	

	cd $WORK_DIR
fi






# Start Hadoop:
#cd $WORK_DIR
#hadoop namenode -format
#./hadoop/sbin/start-all.sh

# Start Spark:
#./spark/sbin/start-all.sh
