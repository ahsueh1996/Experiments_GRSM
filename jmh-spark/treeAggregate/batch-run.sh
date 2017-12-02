PD=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate

cd $PD

sh run.sh aggressive standalone jmh_infused
sh run.sh maxMargin_less_cmp standalone jmh_infused
sh run.sh less_fcmp standalone jmh_infused
sh run.sh int_label standalone jmh_infused
