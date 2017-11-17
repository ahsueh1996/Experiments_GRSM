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

########################################################PART 1######################################################
# Basic dependecies needed:
yum -y install gcc glibc-headers git autoconf automake libtool gcc-c++ cmake vim zlib-devel openssl-devel svn cpan libssh2-devel iptables-services tree bzip2 perl-devel perf sysstat 

#
# Get a JDK
#
cd $WORK_DIR
if [ "$ARM_MACHINE" = true ] ; then
  wget http://openjdk.linaro.org/releases/jdk8u-server-release-1708.tar.xz
  tar -xf jdk8u-server-release-1708.tar.xz
  rm -f jdk8u-server-release-1708.tar.xz
  echo "export JAVA_HOME=$WORK_DIR/jdk8u-server-release-1708"  >> ~/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin"  >> ~/.bashrc
else
  wget https://github.com/AdoptOpenJDK/openjdk8-releases/releases/download/jdk8u144-b01/OpenJDK8_x64_Linux_jdk8u144-b01.tar.gz
  tar -xzf OpenJDK8_x64_Linux_jdk8u144-b01.tar.gz
  rm -f OpenJDK8_x64_Linux_jdk8u144-b01.tar.gz
  echo "export JAVA_HOME=$WORK_DIR/OpenJDK8_x64_Linux_jdk8u144-b01"  >> ~/.bashrc
  echo "export PATH=\$PATH:\$JAVA_HOME/bin"  >> ~/.bashrc
fi

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

source ~/.bashrc
