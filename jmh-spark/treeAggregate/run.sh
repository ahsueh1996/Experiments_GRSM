#!/bin/bash
if [ "$1" != "large_pages" ] && [ "$1" != "maxMargin_less_if" ] && [ "$1" != "baseline" ] && [ "$1" != "conglomerate" ] && [ "$1" != "info" ] && [ "$1" != "int_label" ] ; then
	echo undef optimization, choose from:
	echo large_pages, maxMargin_less_if, baseline, conglomerate, info, int_label
	exit
fi

if [ "$2" != "standalone" ] && [ "$2" != "local" ] ; then
	echo please specify spark master mode:
	echo standalone, local
	exit
fi

if [ "$3" = "no_jmh" ] ; then
	jmh_infused=false
else
	jmh_infused=true
fi

OUTPUT_DIR=/home/hibench-output/$1_$2
WORK_DIR=/CMC/kmiecseb
PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
TARGET_DIR=$PROJ_DIR/target

cd $TARGET_DIR

########################################################################################################

# Reset the OUTPUT_DIR
mkdir -p $OUTPUT_DIR
yes 'yes' | rm -R $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/lr

# Check for WORK_DIR
if [ ! -d "$WORK_DIR" ]; then
	echo "The current work directory \"$WORK_DIR\" does not exist, exiting..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	exit
fi

# Check for HiBench
if [ ! -d "$WORK_DIR/HiBench" ]; then
	echo "HiBench does not appear in the current working directory \"$WORK_DIR\", exiting..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	exit
fi


########################################################################################################
######################            Starting tuning epxeriment       ############################################
########################################################################################################
date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "\e[95m===============================================" |  tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "Starting experiment: "$OUTPUT_DIR | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt

MY_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo my ip: | tee -a $OUTPUT_DIR/lr/experiment_log.txt 
echo $MY_IP | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo end | tee -a $OUTPUT_DIR/lr/experiment_log.txt
sleep 2

########################################################################################################
######################            Starting spark master     ############################################
########################################################################################################
echo -e "\e[95m===============================================" |  tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "Restarting Spark Master @ $MY_IP:7077" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt

date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
cd $WORK_DIR
sh reset.sh
date | tee -a $OUTPUT_DIR/lr/experiment_log.txt

echo -e "\e[95m===============================================" |  tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "To check the webUI to see the spark master," | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "  run the following: ssh -L 8080:localhost:8080 root@"$MY_IP | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "  then do following: xdg-open "$MY_IP":8080" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
sleep 10

########################################################################################################
#######################          Prep data    ############################################
########################################################################################################

cd $WORK_DIR/HiBench			# Run Hibench scripts from this directory

PROBLEM_FEATURES=(150000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf

for i in "${PROBLEM_FEATURES[@]}"
do
	# Reset and create folders:
	hadoop fs -rmr /HiBench/LR | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	mkdir -p $OUTPUT_DIR/lr/$i

	# Generate data
	echo -e "\e[95m===============================================" |  tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo "Preparing for LR example, input size $i features...." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	sed -i "s#.*hibench.lr.huge.features.*#hibench.lr.huge.features    $i#g" conf/workloads/ml/lr.conf
	./bin/workloads/ml/lr/prepare/prepare.sh | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
  
  ########################################################################################################
  #######################          vary conf and run    ############################################
  ########################################################################################################
  	
	export MY_SPARK_WORKER_MEMORY=122g
	if [ "$IS_ARM" = true ] ; then
		export MY_SPARK_WORKER_CORES=90
		export MY_SPARK_EXECUTOR_INSTANCES=6
		export MY_SPARK_EXECUTOR_CORES=15
		export MY_SPARK_DRIVER_MEMORY=24g
		export MY_SPARK_EXECUTOR_MEMORY=16g
	else
		export MY_SPARK_WORKER_CORES=30
		if [ "$2" = "local" ] ; then
			export MY_SPARK_EXECUTOR_INSTANCES=5
			export MY_SPARK_EXECUTOR_CORES=5
			export MY_SPARK_DRIVER_MEMORY=24g
			export MY_SPARK_EXECUTOR_MEMORY=24g
		else
			export MY_SPARK_EXECUTOR_INSTANCES=2
			export MY_SPARK_EXECUTOR_CORES=14
			export MY_SPARK_DRIVER_MEMORY=8g
			export MY_SPARK_EXECUTOR_MEMORY=57g
		fi
	fi
	if [ "$2" = "local" ] ; then
		spark_master="local[*]"
	else
		spark_master="spark://$MY_IP:7077"
	fi
	export MY_SPARK_DEFAULT_PARALLELISM=30    
	export MY_SPARK_SQL_SHUFFLE_PARTITIONS=30
		
	#################################################
	if [ "$1" = "baseline" ] ; then
		jar_variant="-$2"
	fi
	if [ "$1" = "large_pages" ] ; then
		jvm_options="--driver-java-options \"-XX:+UseLargePages\""
		jar_variant="-$2"
	fi
	if [ "$1" = "maxMargin_less_if" ] ; then
		jar_variant="-mMLessIf-$2"
	fi
	if [ "$1" = "conglomerate" ] ; then
		jvm_options="--driver-java-options \"-XX:+UseLargePages\""
		jar_variant="-mMLessIf-$2"
	fi	
	if [ "$1" = "info" ] ; then
		jar_variant="-info-$2"
	fi
	if [ "$1" = "int_label" ] ; then
		jar_variant="-intLabel-$2"
	fi	
	if [ "$jmh_infused" = true ] ; then
		variable=(trial)
	else
		variable=(t0 t1 t2 t3 t4 t5)
	fi
	##################################################


  for j in "${variable[@]}"
  do
    # run configs
    yes 'yes' | sh $PROJ_DIR/../setup/config.sh | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	
    # Run Spark-Based Benchmark, using the JMH infused jar:
    echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo "Starting Spark LR example, $i features, $j $1, @ $spark_master..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    if [ "$jmh_infused" = true ] ; then
	echo -e "\e[91mCHECK to make sure sparkmasters match!!!!!!\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	sleep 3
    fi
    date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	if [ "$jmh_infused" = true ] ; then
		yes 'yes' | cp $PROJ_DIR/.target/benchmarks${jar_variant}.jar $PROJ_DIR/.target/tmp-benchmarks.jar
	  	$WORK_DIR/spark/bin/spark-submit $jvm_options --properties-file $PROJ_DIR/myspark.conf --master $spark_master --driver-class-path $PROJ_DIR/.target/benchmarks${jar_variant}.jar $PROJ_DIR/.target/benchmarks${jar_variant}.jar | tee -a $OUTPUT_DIR/lr/experiment_log.txt
		yes 'yes' | rm $PROJ_DIR/.target/tmp-benchmarks.jar
	else
		$WORK_DIR/spark/bin/spark-submit $jvm_options --properties-file $PROJ_DIR/myspark.conf --class com.intel.hibench.sparkbench.ml.LogisticRegression --master $spark_master /CMC/kmiecseb/HiBench/sparkbench/assembly/target/sparkbench-assembly-6.1-SNAPSHOT-dist.jar hdfs://localhost:9000/HiBench/LR/Input | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	fi 
    date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo "Finished Spark LR example." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    # Move results to output directory
    cd $WORK_DIR/HiBench
    mv report/* $OUTPUT_DIR/lr/$i/
  done

done

date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "Done experiment." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
########################################################################################################
