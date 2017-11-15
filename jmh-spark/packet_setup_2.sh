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

########################################################PART 2######################################################
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
