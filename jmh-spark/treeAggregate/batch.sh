PD=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate

cd $PD

sh run.sh info local jmh_infused
#sh run.sh baseline standalone jmh_infused
sh run.sh aggressive local jmh_infused
#sh run.sh large_pages standalone jmh_infused
sh run.sh maxMargin_less_cmp local jmh_infused
#sh run.sh maxMargin_less_if standalone jmh_infused
sh run.sh less_fcmp local jmh_infused
#sh run.sh maxMargin_less_if standalone jmh_infused
sh run.sh int_label local jmh_infused
#sh run.sh maxMargin_less_if standalone jmh_infused
sh run.sh conglomerate local jmh_infused
#sh run.sh conglomerate standalone jmh_infused
