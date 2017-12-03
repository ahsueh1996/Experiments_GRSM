PD=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate

cd $PD

#sh run.sh baseline standalone
sh run.sh baseline local
sh run.sh large_pages local
#sh run.sh large_pages standalone
sh run.sh aggressive local
sh run.sh aggressive standalone jmh_infused
sh run.sh maxMargin_less_cmp standalone jmh_infused
sh run.sh less_fcmp standalone jmh_infused
sh run.sh int_label standalone jmh_infused
sh run.sh maxMargin_less_if standalone
sh run.sh maxMargin_less_cmp local jmh_infused
sh run.sh less_fcmp local jmh_infused
sh run.sh int_label local jmh_infused
sh run.sh maxMargin_less_if local
