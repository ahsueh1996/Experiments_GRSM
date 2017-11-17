#!/bin/bash
# choose avgt, perfnorm, or perfasm
OUTPUT_DIR=/home/hibench-output/avgt
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
	PROBLEM_FEATURES=(3000)
## big set ###
#	PROBLEM_FEATURES=(350000 400000 450000 500000)

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
	echo you have 3 min to check out the input
	sleep 180

	date

	hadoop fs -rm /HiBench/LR -r

done

########################################################################################################
