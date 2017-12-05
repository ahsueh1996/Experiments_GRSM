PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/order
cd $PROJ_DIR
mkdir -p $PROJ_DIR/results/temp
touch results/temp/experiment_log.txt
echo Notes: $1 >> results/temp/experiment_log.txt
java -jar target/benchmarks.jar | tee -a results/temp/experiment_log.txt

