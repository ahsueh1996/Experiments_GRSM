#!/bin/bash
# choose avgt, perfnorm, or perfasm
OUTPUT_DIR=/home/hibench-output/perfnorm
WORK_DIR=/CMC/kmiecseb
PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
mkdir -p $OUTPUT_DIR
yes 'yes' | rm -R $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/lr

# Check for WORK_DIR
if [ ! -d "$WORK_DIR" ]; then
	echo "The current work directory \"$WORK_DIR\" does not exist, exiting..." | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	exit
fi

# Check for HiBench
if [ ! -d "$WORK_DIR/HiBench" ]; then
	echo "HiBench does not appear in the current working directory \"$WORK_DIR\", exiting..." | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	exit
fi


########################################################################################################
########################################################################################################
########################################################################################################
cd $WORK_DIR
sh reset.sh
cd $WORK_DIR/HiBench			# Run Hibench scripts from this directory
########################################################################################################
########################################################################################################
##### Run Logistic Regression problems #################################################################
## small set###
#	PROBLEM_FEATURES=(50 250 750 1500 3000)
## big set ###
	PROBLEM_FEATURES=(350000 400000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf

MY_SM=spark://$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'):7077
echo $MY_SM | tee $OUTPUT_DIR/lr/my_spark_master.txt

for i in "${PROBLEM_FEATURES[@]}"
do

	# Generate data
	echo -e "\e[95m===============================================" |  tee $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo "Preparing for LR example, input size $i features...." | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	sed -i "s#.*hibench.lr.huge.features.*#hibench.lr.huge.features    $i#g" conf/workloads/ml/lr.conf
	./bin/workloads/ml/lr/prepare/prepare.sh | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt

	# Run Spark-Based Benchmark, using the JMH infused jar:
	echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo "Starting Spark LR example, input size $i features..." | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	mkdir -p $OUTPUT_DIR/lr/$i
	cd $PROJ_DIR
	##############
	#####avgt#####
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file "/CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark" --name "HiBench LR with JMH" --master $MY_SM --driver-class-path "target/benchmarks.jar" target/benchmarks.jar | tee $OUTPUT_DIR/lr/$i/log.txt
	###perfnorm###
		/CMC/kmiecseb/spark/bin/spark-submit --properties-file /CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark --name "HiBench LR with JMH" --master $MY_SM --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfnorm | tee $OUTPUT_DIR/lr/$i/log.txt
	###perfasm####
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file /CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark --name "HiBench LR with JMH" --master $MY_SM --driver-java-options "-XX:+UnlockDiagnosticVMOptions -XX:CompileCommand=print,*Benchmarks.HiBench_LR" --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfasm | tee $OUTPUT_DIR/lr/$i/log.txt
	#######
	cd $WORK_DIR/HiBench
	echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo "Finished Spark LR example, input size $i features." | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	date | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt

	# Move results to output directory
	mv report/* $OUTPUT_DIR/lr/$i/

	# Cleanup:
	hadoop fs -rm /HiBench/LR/Input | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt
	hadoop fs -rmr /HiBench/LR | tee -a $OUTPUT_DIR/lr/$i/experiment_log.txt

done

########################################################################################################
