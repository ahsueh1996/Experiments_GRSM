PROJ_DIR=/home/hsuehku1/Experiments_GRSM/jmh-spark/order
cd $PROJ_DIR
mkdir -p /home/hibench-output/results
touch results/experiment_log.txt
echo Notes: $1 >> results/experiment_log.txt
java -jar target/benchmarks.jar -wm BULK | tee -a results/experiment_log.txt

