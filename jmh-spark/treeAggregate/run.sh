#!/bin/bash
# choose avgt, perfnorm, or perfasm
OUTPUT_DIR=/home/hibench-output/perfasm_temps
WORK_DIR=/CMC/kmiecseb
PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate

Reset the OUTPUT_DIR
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
######################            Starting epxeriment       ############################################
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
#######################          Run Logistic Regression    ############################################
########################################################################################################

cd $WORK_DIR/HiBench			# Run Hibench scripts from this directory


######################		Choose one 	########################################################
# small set
#	PROBLEM_FEATURES=(50 250 750 1500 3000)
# big set
#	PROBLEM_FEATURES=(350000 400000 450000 500000)
# custom
	PROBLEM_FEATURES=(400000)
########################################################################################################

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

	# Run Spark-Based Benchmark, using the JMH infused jar:
	echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo "Starting Spark LR example, input size $i features..." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	cd $PROJ_DIR
	date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	

	##############		Choose one   #############################################################
	# avgt
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file "/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/myspark.conf" --driver-class-path "target/benchmarks.jar" target/benchmarks.jar | tee $OUTPUT_DIR/lr/$i/log.txt
	# perfnorm
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file "/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/myspark.conf" --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfnorm | tee $OUTPUT_DIR/lr/$i/log.txt
	# perfasm
		/CMC/kmiecseb/spark/bin/spark-submit --properties-file "/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/myspark.conf" --driver-java-options "-XX:+UnlockDiagnosticVMOptions -XX:CompileCommand=print,*Benchmarks.HiBench_LR" --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfasm | tee $OUTPUT_DIR/lr/$i/log.txt
	##################################################################################################

	date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	cd $WORK_DIR/HiBench
	echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo "Finished Spark LR example, input size $i features." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
	echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt

	# Move results to output directory
	mv report/* $OUTPUT_DIR/lr/$i/

done

date | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "\e[95m===============================================" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo "Done experiment." | tee -a $OUTPUT_DIR/lr/experiment_log.txt
echo -e "================================================\e[97m" | tee -a $OUTPUT_DIR/lr/experiment_log.txt
########################################################################################################
