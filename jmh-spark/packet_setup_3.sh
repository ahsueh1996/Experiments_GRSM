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

########################################################PART 3######################################################
### go to work_dir to check whether it's has been done or not ###
cd $WORK_DIR

# Grab Hadoop...
#
if [  ! -d "hadoop"  ];then

 	printf "\nGrabbing and preparing Hadoop 2.7.1...\n"

 	# Grab and build Hadoop 2.7.1:
	cd $WORK_DIR
	wget https://github.com/apache/hadoop/archive/release-2.7.1.tar.gz
	tar -xf release-2.7.1.tar.gz
	cd hadoop-release-2.7.1
	mvn clean package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X >> /dev/null
	mvn package -Pdist,native -DskipTests -Dtar -X
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


######### do this at the start ############
# 	# Setup SSH keys for sshing to self:
# 	#
# 	echo "y" |  ssh-keygen -t dsa -f ~/.ssh/id_dsa -P ""
# 	cat ~/.ssh/id_dsa.pub >>  ~/.ssh/authorized_keys
# 	chmod 0600 ~/.ssh/authorized_keys
# 	ssh -o "StrictHostKeyChecking no" localhost "exit"	&
# 	ssh -o "StrictHostKeyChecking no" 0.0.0.0 "exit" &
# 	ssh -o "StrictHostKeyChecking no" $('hostname') "exit"	&
# 	LOCAL_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
# 	ssh -o "StrictHostKeyChecking no" $LOCAL_IP "exit"	&
# 	cd $WORK_DIR
  
else
  echo seems like hadoop has been grabbed already
  
fi
