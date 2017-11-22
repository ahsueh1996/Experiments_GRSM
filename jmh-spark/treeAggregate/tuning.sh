!/bin/bash
# choose tuning local or URL
OUTPUT_DIR=/home/hibench-output/tuning_url/executor_instnaces
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

PROBLEM_FEATURES=(250000)

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
	executor_instnace=(1 15 3 9 5)
  for j in "${executor_instnace[@]}"
  do
    mkdir -p $OUTPUT_DIR/lr/$i/$j
    if [ "$MY_IS_ARM" = true ] ; then
      export MY_SPARK_WORKER_CORES=90 
    else
      export MY_SPARK_WORKER_CORES=30
    fi
    export MY_SPARK_EXECUTOR_MEMORY="$(expr 110 / $j)g"
    export MY_SPARK_EXECUTOR_CORES=$(expr $MY_SPARK_WORKER_CORES / $j)
    export MY_SPARK_DEFAULT_PARALLELISM=$MY_SPARK_WORKER_CORES        
    export MY_SPARK_SQL_SHUFFLE_PARTITIONS=$MY_SPARK_WORKER_CORES
    export MY_SPARK_EXECUTOR_INSTANCES=$j
    
    yes 'yes' | sh $PROJ_DIR/../setup/config.sh | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	
    # Run Spark-Based Benchmark, using the JMH infused jar:
    echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo "Starting Spark LR example, $i features, $j executor instances..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	  $WORK_DIR/spark/bin/spark-submit --properties-file $PROJ_DIR/myspark.conf --class com.intel.hibench.sparkbench.ml.LogisticRegression --master spark://$MY_IP:7077  /CMC/kmiecseb/HiBench/sparkbench/assembly/target/sparkbench-assembly-6.1-SNAPSHOT-dist.jar hdfs://localhost:9000/HiBench/LR/Input | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo "Finished Spark LR example, input size $i features." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
    echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt

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
