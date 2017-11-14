#!/bin/bash
OUTPUT_DIR=/home/hibench-output
WORK_DIR=/CMC/kmiecseb
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
cd $WORK_DIR/HiBench










##### Run ALS problems ###############################################
#####
##### NOTE: Problem sizes larger than 21000 seem to be buggy and unreliable.

PROBLEM_USERS=(10000 12500 15000 17500)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_USERS[@]}"
do
        # Problem input generated is ((users),(products)):
        PRODUCTS=$((3 * $i / 2))

        # Generate data
        printf "\n\n\nPreparing for ALS example, input size $i users....\n\n\n"
        date
        sed -i "s#.*hibench.als.huge.users.*#hibench.als.huge.users    $i#g" conf/workloads/ml/als.conf
        sed -i "s#.*hibench.als.huge.products.*#hibench.als.huge.products    $PRODUCTS#g" conf/workloads/ml/als.conf
        ./bin/workloads/ml/als/prepare/prepare.sh &> /dev/null
        date


        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting ALS example, input size $i users...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/als/$i
        ./bin/workloads/ml/als/spark/run.sh
        wait
        date

        # Move results to output directory
        mv report/* $OUTPUT_DIR/als/$i/

        # Cleanup:
        hadoop fs -rmr /HiBench/ALS

done

########################################################################################################










##### Run SVD problems ###############################################
#####
PROBLEM_EXAMPLES=(5000 5500 6000 6500 7000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_EXAMPLES[@]}"
do

        # Generate data
        printf "\n\n\nPreparing for SVD example, input size $i examples....\n\n\n"
        date
        sed -i "s#.*hibench.svd.huge.examples.*#hibench.svd.huge.examples    $i#g" conf/workloads/ml/svd.conf
        sed -i "s#.*hibench.svd.huge.features.*#hibench.svd.huge.features    $i#g" conf/workloads/ml/svd.conf
        ./bin/workloads/ml/svd/prepare/prepare.sh &> /dev/null
        date


        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting SVD example, input size $i examples...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/svd/$i
        ./bin/workloads/ml/svd/spark/run.sh
        wait
        date

        # Move results to output directory
        mv report/* $OUTPUT_DIR/svd/$i/

        # Cleanup:
        hadoop fs -rmr /HiBench/SVD

done

########################################################################################################










##### Run RF problems ###############################################
#####
PROBLEM_EXAMPLES=(9000 10000 11000 12000 13000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_EXAMPLES[@]}"
do
	    FEATURES=$((30 * $i))

        # Generate data
        printf "\n\n\nPreparing for RF example, input size $i examples....\n\n\n"
        date
        sed -i "s#.*hibench.rf.huge.examples.*#hibench.rf.huge.examples    $i#g" conf/workloads/ml/rf.conf
        sed -i "s#.*hibench.rf.huge.features.*#hibench.rf.huge.features    $FEATURES#g" conf/workloads/ml/rf.conf
        ./bin/workloads/ml/rf/prepare/prepare.sh &> /dev/null
        date


        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting RF example, input size $i examples...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/rf/$i
        ./bin/workloads/ml/rf/spark/run.sh
        wait
        date

        # Move results to output directory
        mv report/* $OUTPUT_DIR/rf/$i/

        # Cleanup:
        hadoop fs -rmr /HiBench/RF

done

########################################################################################################











##### Run WORD COUNT problems ###############################################
#####
PROBLEM_SIZES_GB_S=(50 100 150 200)
PROBLEM_SIZES_GB_H=(50 75 100 125 150)
GB="000000000"

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf



for i in "${PROBLEM_SIZES_GB_H[@]}"
do
	# Generate data
	printf "\n\n\nPreparing for word count example, input size $i GB....\n\n\n"
	date
	sed -i "s#.*hibench.wordcount.huge.datasize.*#hibench.wordcount.huge.datasize    $i$GB#g" conf/workloads/micro/wordcount.conf
	bin/workloads/micro/wordcount/prepare/prepare.sh &> /dev/null
	dat

	# Run Hadoop-Based Benchmark:
	printf "\n\n\nStarting HADOOP word count example, input size $i GB...\n\n\n"
	date
	mkdir -p $OUTPUT_DIR/wc/hadoop/$i/
	./bin/workloads/micro/wordcount/hadoop/run.sh
	date


	# Move other results to output directory
	mv report/* $OUTPUT_DIR/wc/hadoop/$i/



	# Cleanup:
	hadoop fs -rmr /HiBench/Wordcount

done




for i in "${PROBLEM_SIZES_GB_S[@]}"
do
        # Generate data
        printf "\n\n\nPreparing for word count example, input size $i GB....\n\n\n"
        date
        sed -i "s#.*hibench.wordcount.huge.datasize.*#hibench.wordcount.huge.datasize    $i$GB#g" conf/workloads/micro/wordcount.conf
        bin/workloads/micro/wordcount/prepare/prepare.sh &> /dev/null
        date


        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting SPARK word count example, input size $i GB...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/wc/spark/$i
        ./bin/workloads/micro/wordcount/spark/run.sh
        date


        # Move results to output directory
        mv report/* $OUTPUT_DIR/wc/spark/$i/



        # Cleanup:
        hadoop fs -rmr /HiBench/Wordcount

done

########################################################################################################
########################################################################################################











##### Run Naive Bayes problems ###############################################
#####
PROBLEM_PAGES_S=(2000000 400000 6000000 8000000 10000000 12000000)
PROBLEM_PAGES_H=(400000 500000 600000 700000 800000)

# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_PAGES_H[@]}"
do
	# Generate data
	printf "\n\n\nPreparing for Naive Bayes example, input size $i pages....\n\n\n"
	date
	sed -i "s#.*hibench.bayes.huge.pages.*#hibench.bayes.huge.pages    $i#g" conf/workloads/ml/bayes.conf
	./bin/workloads/ml/bayes/prepare/prepare.sh &> /dev/null
	date

	# Run Hadoop-Based Benchmark:
	printf "\n\n\nStarting Hadoop Naive Bayes example, input size $i pages...\n\n\n"
	date
	mkdir -p $OUTPUT_DIR/bayes/hadoop/$i
	./bin/workloads/ml/bayes/hadoop/run.sh
	date

	# Move results to output directory
	mv report/* $OUTPUT_DIR/bayes/hadoop/$i/

	# Cleanup:
	hadoop fs -rmr /HiBench/Bayes

done

for i in "${PROBLEM_PAGES_S[@]}"
do

        # Generate data
        printf "\n\n\nPreparing for Naive Bayes example, input size $i pages....\n\n\n"
        date
        sed -i "s#.*hibench.bayes.huge.pages.*#hibench.bayes.huge.pages    $i#g" conf/workloads/ml/bayes.conf
        ./bin/workloads/ml/bayes/prepare/prepare.sh &> /dev/null
        date


        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting Spark Naive Bayes example, input size $i pages...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/bayes/spark/$i
        ./bin/workloads/ml/bayes/spark/run.sh
        date

        # Move results to output directory
        mv report/* $OUTPUT_DIR/bayes/spark/$i/

        # Cleanup:
        hadoop fs -rmr /HiBench/Bayes

done

########################################################################################################
	



















##### Run K-means problems ###############################################
#####

#PROBLEM_SAMPLES=(50000000 75000000 100000000 125000000 150000000)
PROBLEM_SAMPLES_H=(50000000 100000000 150000000 200000000 250000000)
PROBLEM_SAMPLES_S=(100000000 200000000 300000000 400000000 500000000)


# Set data size scale to "huge"
sed -i "s#.*hibench.scale.profile.*#hibench.scale.profile      huge#g" conf/hibench.conf


for i in "${PROBLEM_SAMPLES_H[@]}"
do

	SAMPLES_PER_INPUT_FILE=$(($i / 5))

	# Generate data
	printf "\n\n\nPreparing for K-Means example, input size $i samples....\n\n\n"
	date
	sed -i "s#.*hibench.kmeans.huge.num_of_samples.*#hibench.kmeans.huge.num_of_samples    $i#g" conf/workloads/ml/kmeans.conf
	sed -i "s#.*hibench.kmeans.huge.samples_per_inputfile.*#hibench.kmeans.huge.samples_per_inputfile    $SAMPLES_PER_INPUT_FILE#g" conf/workloads/ml/kmeans.conf
	./bin/workloads/ml/kmeans/prepare/prepare.sh &> /dev/null
	date

	# Run Hadoop-Based Benchmark:
	printf "\n\n\nStarting Hadoop K-Means example, input size $i samples...\n\n\n"
	date
	mkdir -p $OUTPUT_DIR/kmeans/hadoop/$i
	./bin/workloads/ml/kmeans/hadoop/run.sh
	date

	# Move results to output directory
	mv report/* $OUTPUT_DIR/kmeans/hadoop/$i/

	# Cleanup:
	hadoop fs -rmr /HiBench/Kmeans

done


for i in "${PROBLEM_SAMPLES_S[@]}"
do

        SAMPLES_PER_INPUT_FILE=$(($i / 5))

        # Generate data
        printf "\n\n\nPreparing for K-Means example, input size $i samples....\n\n\n"
        date
        sed -i "s#.*hibench.kmeans.huge.num_of_samples.*#hibench.kmeans.huge.num_of_samples    $i#g" conf/workloads/ml/kmeans.conf
        sed -i "s#.*hibench.kmeans.huge.samples_per_inputfile.*#hibench.kmeans.huge.samples_per_inputfile    $SAMPLES_PER_INPUT_FILE#g" conf/workloads/ml/kmeans.conf
        ./bin/workloads/ml/kmeans/prepare/prepare.sh &> /dev/null
        date

        # Run Spark-Based Benchmark:
        printf "\n\n\nStarting Spark K-Means example, input size $i samples...\n\n\n"
        date
        mkdir -p $OUTPUT_DIR/kmeans/spark/$i
        ./bin/workloads/ml/kmeans/spark/run.sh
        date

        # Move results to output directory
        mv report/* $OUTPUT_DIR/kmeans/spark/$i/


        # Cleanup:
        hadoop fs -rmr /HiBench/Kmeans

done

########################################################################################################
	













##### Run Logistic Regression problems ###############################################
#####
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

	# Run Spark-Based Benchmark:
	printf "\n\n\nStarting Spark LR example, input size $i features...\n\n\n"
	date
	mkdir -p $OUTPUT_DIR/lr/$i
	./bin/workloads/ml/lr/spark/run.sh
	date

	# Move results to output directory
	mv report/* $OUTPUT_DIR/lr/$i/

	# Cleanup:
	hadoop fs -rmr /HiBench/LR

done

########################################################################################################
