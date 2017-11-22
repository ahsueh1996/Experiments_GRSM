#!/bin/bash
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

read -p "Enter to continue: "

export OLD_IS_ARM=${IS_ARM}
export OLD_MY_USE_YARN_FOR_SPARK_ON_HADOOP=${MY_USE_YARN_FOR_SPARK_ON_HADOOP}
export OLD_MY_YARN_CORES=${MY_YARN_CORES}
export OLD_MY_ARN_MEM=${MY_YARN_MEM}	
export OLD_MY_SPARK_EXECUTOR_CORES=${MY_SPARK_EXECUTOR_CORES}
export OLD_MY_SPARK_EXECUTOR_MEMORY=${MY_SPARK_EXECUTOR_MEMORY}
export OLD_MY_SPARK_DRIVER_MEMORY=${MY_SPARK_DRIVER_MEMORY}
export OLD_MY_SPARK_WORKER_CORES=${MY_SPARK_WORKER_CORES}
export OLD_MY_SPARK_WORKER_MEMORY=${MY_SPARK_WORKER_MEMORY}
export OLD_MY_SPARK_WORKER_INSTANCES=${MY_SPARK_WORKER_INSTANCES}
export OLD_MY_SPARK_EXECUTOR_INSTANCES=${MY_SPARK_EXECUTOR_INSTANCES}
export OLD_MY_SPARK_DAEMON_MEMORY=${MY_SPARK_DAEMON_MEMORY}

########################################################HEADER######################################################
assert_equal () {
  if [ "$3" != "$2" ] ; then 
    echo -e "\e[31mOld setting for $1 is:\e[39m $3"
    exit
  fi
}

assert_equal ${OLD_IS_ARM} ${IS_ARM} "IS_ARM"
assert_equal ${OLD_MY_USE_YARN_FOR_SPARK_ON_HADOOP} ${MY_USE_YARN_FOR_SPARK_ON_HADOOP} "MY_USE_YARN_FOR_SPARK_ON_HADOOP"
assert_equal ${OLD_MY_YARN_CORES} ${MY_YARN_CORES} "MY_YARN_CORES"
assert_equal ${OLD_MY_ARN_MEM} ${MY_YARN_MEM}	"MY_YARN_MEM"
assert_equal ${OLD_MY_SPARK_EXECUTOR_CORES} ${MY_SPARK_EXECUTOR_CORES} "MY_SPARK_EXECUTOR_CORES"
assert_equal ${OLD_MY_SPARK_EXECUTOR_MEMORY} ${MY_SPARK_EXECUTOR_MEMORY} "MY_SPARK_EXECUTOR_MEMORY"
assert_equal ${OLD_MY_SPARK_DRIVER_MEMORY} ${MY_SPARK_DRIVER_MEMORY} "MY_SPARK_DRIVER_MEMORY"
assert_equal ${OLD_MY_SPARK_WORKER_CORES} ${MY_SPARK_WORKER_CORES} "MY_SPARK_WORKER_CORES"
assert_equal ${OLD_MY_SPARK_WORKER_MEMORY} ${MY_SPARK_WORKER_MEMORY} "MY_SPARK_WORKER_MEMORY"
assert_equal ${OLD_MY_SPARK_WORKER_INSTANCES} ${MY_SPARK_WORKER_INSTANCES} "MY_SPARK_WORKER_INSTANCES"
assert_equal ${OLD_MY_SPARK_EXECUTOR_INSTANCES} ${MY_SPARK_EXECUTOR_INSTANCES} "MY_SPARK_EXECUTOR_INSTANCES"
assert_equal ${OLD_MY_SPARK_DAEMON_MEMORY} ${MY_SPARK_DAEMON_MEMORY} "MY_SPARK_DAEMON_MEMORY"

# General Settings:
# Where Hadoop, Spark, etc is built and stored
WORK_DIR=/CMC/kmiecseb
# Is this in fact an ARM machine (not an x86)					
ARM_MACHINE=${IS_ARM}
# true: use YARN, false: use Spark's standalone resource manager						 
USE_YARN_FOR_SPARK_ON_HADOOP=${MY_USE_YARN_FOR_SPARK_ON_HADOOP}

# Hadoop-YARN settings:
# Number of cores to use for Hadoop and Spark on Hadoop jobs (if using YARN). 92
YARN_CORES=${MY_YARN_CORES}
# Amount of memory to use for Hadoop and Spark on Hadoop jobs (if using YARN).			 112640	
YARN_MEM=${MY_YARN_MEM}				

# Spark settings:  10 10G 10G 92 100G 1 9 2G
SPARK_EXECUTOR_CORES=${MY_SPARK_EXECUTOR_CORES}
SPARK_EXECUTOR_MEMORY=${MY_SPARK_EXECUTOR_MEMORY}
SPARK_DRIVER_MEMORY=${MY_SPARK_DRIVER_MEMORY}
SPARK_WORKER_CORES=${MY_SPARK_WORKER_CORES}
SPARK_WORKER_MEMORY=${MY_SPARK_WORKER_MEMORY}
SPARK_WORKER_INSTANCES=${MY_SPARK_WORKER_INSTANCES}
SPARK_EXECUTOR_INSTANCES=${MY_SPARK_EXECUTOR_INSTANCES}
SPARK_DAEMON_MEMORY=${MY_SPARK_DAEMON_MEMORY}
########################################################BODY######################################################
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
  echo "export JAVA_HOME=$WORK_DIR/jdk8u144-b01"  >> ~/.bashrc
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
