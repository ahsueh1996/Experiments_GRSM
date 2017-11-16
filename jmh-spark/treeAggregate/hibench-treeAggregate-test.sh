#!/bin/bash
# choose avgt, perfnorm, or perfasm
OUTPUT_DIR=/home/hibench-output/perfasm
WORK_DIR=/CMC/kmiecseb
PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
mkdir -p $OUTPUT_DIR
yes 'yes' | rm -R $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Check for WORK_DIR
if [ ! -d "$WORK_DIR" ]; then
	echo "The current work directory \"$WORK_DIR\" does not exist, exiting..."
	exit
fi

# Check for HiBench
if [ ! -d "$WORK_DIR/HiBench" ]; then
	echo "HiBench does not appear in the current working directory \"$WORK_DIR\", exiting..."
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
	PROBLEM_FEATURES=(350000 400000 450000 500000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_FEATURES[@]}"
do

	# Generate data
	printf "\n\n\nPreparing for LR example, input size $i features....\n\n\n"
	date
	sed -i "s#.*hibench.lr.huge.features.*#hibench.lr.huge.features    $i#g" conf/workloads/ml/lr.conf
	./bin/workloads/ml/lr/prepare/prepare.sh &> /dev/null
	date

	# Run Spark-Based Benchmark, using the JMH infused jar:
	printf "\n\n\nStarting Spark LR example, input size $i features...\n\n\n"
	date
	mkdir -p $OUTPUT_DIR/lr/$i
	cd $PROJ_DIR
	##############
	#####avgt#####
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file /CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark --master spark://142.150.237.146:7077 --driver-class-path "target/benchmarks.jar" target/benchmarks.jar | tee $OUTPUT_DIR/lr/$i/log.txt
	###perfnorm###
	#	/CMC/kmiecseb/spark/bin/spark-submit --properties-file /CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark --master spark://142.150.237.146:7077 --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfnorm | tee $OUTPUT_DIR/lr/$i/log.txt
	###perfasm####
		/CMC/kmiecseb/spark/bin/spark-submit --properties-file /CMC/kmiecseb/HiBench/conf/spark.conf.jmhspark --master spark://142.150.237.146:7077 --driver-java-options "-XX:+UnlockDiagnosticVMOptions -XX:CompileCommand=print,*Benchmarks.HiBench_LR" --driver-class-path "target/benchmarks.jar" target/benchmarks.jar -prof perfasm | tee $OUTPUT_DIR/lr/$i/log.txt
	#######
	cd $WORK_DIR/HiBench
	date

	# Move results to output directory
	mv report/* $OUTPUT_DIR/lr/$i/

	# Cleanup:
	hadoop fs -rm /HiBench/LR -r

done

########################################################################################################
