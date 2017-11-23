!/bin/bash
if [ "$1" != "executor_instances" ] && [ "$1" != "executor_cores" ] && [ "$1" != "parallelism" ] && [ "$1" != "driver_memory" ] && [ "$1" = "master_sel" ] ; then
	echo undef tuning op, choose from:
	echo executor_instances, executor_cores, parallelism, driver_memory, spark_master
	exit
fi

OUTPUT_DIR=/home/hibench-output/$1
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
  	if [ "$1" = "executor_instances" ] ; then
		if [ "$IS_ARM" = true ] ; then
			export MY_SPARK_WORKER_CORES=90
		else
			export MY_SPARK_WORKER_CORES=30
		fi
		variable=(1 2 3 4 5 6 7 8)
	fi
	if [ "$1" = "executor_cores" ] ; then
		if [ "$IS_ARM" = true ] ; then
			export MY_SPARK_WORKER_CORES=90
			export MY_SPARK_EXECUTOR_INSTANCES=6
			variable=(1 15 3 12 6 9)
		else
			export MY_SPARK_WORKER_CORES=30
			export MY_SPARK_EXECUTOR_INSTANCES=2
			variable=(1 15 3 12 6 9)
		fi
	fi
  	if [ "$1" = "parallelism" ] ; then
		if [ "$IS_ARM" = true ] ; then
			export MY_SPARK_WORKER_CORES=90
			export MY_SPARK_EXECUTOR_INSTANCES=6
			export MY_SPARK_EXECUTOR_CORES=14
			variable=(1 15 3 12 6 9)
		else
			export MY_SPARK_WORKER_CORES=30
			export MY_SPARK_EXECUTOR_INSTANCES=2
			export MY_SPARK_EXECUTOR_CORES=14
			variable=(28 30 1 25 8 16 22)
		fi
	fi
	if [ "$1" = "master_sel" ] ; then
		if [ "$IS_ARM" = true ] ; then
			export MY_SPARK_WORKER_CORES=90
			export MY_SPARK_EXECUTOR_INSTANCES=6
			export MY_SPARK_EXECUTOR_CORES=14
			variable=("spark://$MY_IP:7077" "spark://$MY_IP:7077" "local[*]" "local[28]" "local[2]" "local[5]" "local[30]" "local[12]" "local[18]" "local[22]" "local[25]")
		else
			export MY_SPARK_WORKER_CORES=30
			export MY_SPARK_EXECUTOR_INSTANCES=2
			export MY_SPARK_EXECUTOR_CORES=14
			variable=("spark://$MY_IP:7077" "spark://$MY_IP:7077" "local[*]" "local[28]" "local[2]" "local[5]" "local[30]" "local[12]" "local[18]" "local[22]" "local[25]")
		fi
			export MY_SPARK_DEFAULT_PARALLELISM=$MY_SPARK_WORKER_CORES        
			export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$MY_SPARK_WORKER_CORES	
	fi	
	if [ "$1" = "driver_memory" ] ; then
		if [ "$IS_ARM" = true ] ; then
			export MY_SPARK_WORKER_CORES=90
			export MY_SPARK_EXECUTOR_INSTANCES=6
			export MY_SPARK_EXECUTOR_CORES=14
		else
			export MY_SPARK_WORKER_CORES=30
			export MY_SPARK_EXECUTOR_INSTANCES=2
			export MY_SPARK_EXECUTOR_CORES=14
		fi
		variable=(12 12 10 8 6 4 2 1)
		export MY_SPARK_DEFAULT_PARALLELISM=$MY_SPARK_WORKER_CORES        
		export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$MY_SPARK_WORKER_CORES
	fi
	##################################################
  for j in "${variable[@]}"
  do
  	if [ "$1" = "driver_memory" ] ; then
		export MY_SPARK_WORKER_MEMORY_num=122
		export MY_SPARK_DRIVER_MEMORY_num=$j
		export MY_SPARK_WORKER_MEMORY="${MY_SPARK_WORKER_MEMORY_num}g"
		export MY_SPARK_DRIVER_MEMORY="${MY_SPARK_DRIVER_MEMORY}g"
		export MY_SPARK_EXECUTOR_MEMORY="$(expr \( $MY_SPARK_WORKER_MEMORY_num - $MY_SPARK_DRIVER_MEMORY_num \) / $MY_SPARK_EXECUTOR_INSTANCES)g"		
	else
		export MY_SPARK_WORKER_MEMORY_num=122
		export MY_SPARK_DRIVER_MEMORY_num=12
		export MY_SPARK_WORKER_MEMORY="${MY_SPARK_WORKER_MEMORY_num}g"
		export MY_SPARK_DRIVER_MEMORY="${MY_SPARK_DRIVER_MEMORY}g"
	fi
	if [ "$1" = "executor_instances" ] ; then
		export MY_SPARK_EXECUTOR_CORES=$(expr $MY_SPARK_WORKER_CORES / $j)
		export MY_SPARK_DEFAULT_PARALLELISM=$MY_SPARK_WORKER_CORES        
		export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$MY_SPARK_WORKER_CORES
		export MY_SPARK_EXECUTOR_INSTANCES=$j
		export MY_SPARK_EXECUTOR_MEMORY="$(expr \( $MY_SPARK_WORKER_MEMORY_num - $MY_SPARK_DRIVER_MEMORY_num \) / $MY_SPARK_EXECUTOR_INSTANCES)g"
	fi
	if [ "$1" = "executor_cores" ] ; then
		export MY_SPARK_EXECUTOR_CORES=$j
		export MY_SPARK_DEFAULT_PARALLELISM=$MY_SPARK_WORKER_CORES        
		export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$MY_SPARK_WORKER_CORES
		export MY_SPARK_EXECUTOR_MEMORY="$(expr \( $MY_SPARK_WORKER_MEMORY_num - $MY_SPARK_DRIVER_MEMORY_num \) / $MY_SPARK_EXECUTOR_INSTANCES)g"
	fi
  	if [ "$1" = "parallelism" ] ; then
	    	export MY_SPARK_DEFAULT_PARALLELISM=$j        
	    	export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$j
		export MY_SPARK_EXECUTOR_MEMORY="$(expr \( $MY_SPARK_WORKER_MEMORY_num - $MY_SPARK_DRIVER_MEMORY_num \) / $MY_SPARK_EXECUTOR_INSTANCES)g"
	fi
	
	if [ "$1" = "master_sel" ] ; then
		if [ "$j" = "spark://$MY_IP:7077" ] ; then
			name="url"
		else
			name=$j
		fi
		spark_master=$j
		export MY_SPARK_EXECUTOR_MEMORY="$(expr \( $MY_SPARK_WORKER_MEMORY_num - $MY_SPARK_DRIVER_MEMORY_num \) / $MY_SPARK_EXECUTOR_INSTANCES)g"
	else
		spark_master=spark://$MY_IP:7077
		name=$j
	fi
	##################################################
	
	# set up logging.txt	
    mkdir -p $OUTPUT_DIR/lr/$i/$name
    touch $OUTPUT_DIR/lr/$i/$name/log.txt
    echo "\n\n\n" >> $OUTPUT_DIR/lr/$i/$name/log.txt
    
    	# run configs
    yes 'yes' | sh $PROJ_DIR/../setup/config.sh | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	
    # Run Spark-Based Benchmark, using the JMH infused jar:
    echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo "Starting Spark LR example, $i features, $j executor instances..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	  $WORK_DIR/spark/bin/spark-submit --properties-file $PROJ_DIR/myspark.conf --class com.intel.hibench.sparkbench.ml.LogisticRegression --master $spark_master /CMC/kmiecseb/HiBench/sparkbench/assembly/target/sparkbench-assembly-6.1-SNAPSHOT-dist.jar hdfs://localhost:9000/HiBench/LR/Input | tee -a $OUTPUT_DIR/lr/$i/$name/log.txt
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
