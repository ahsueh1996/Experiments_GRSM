#!/bin/bash
echo ======================CHECKING using jps======================
echo ====================may be populated =========================
jps
echo ==============================================================
# killing jvms
./spark/sbin/stop-all.sh
./hadoop/sbin/stop-all.sh
echo ======================CHECKING using jps======================
echo ====================should be empty ==========================
jps
echo ==============================================================
sleep 4
# removing dfs.name/data.dir stuff
rm -rf hadoop_file
# removing log files
rm -rf spark/work/*
rm -rf hadoop/logs/*
rm -rf /var/log/sa/*
rm -rf HiBench/report/*
# create spark-logs folder
mkdir -p /CMC/kmiecseb/hadoop_file/spark-logs
# formating hadoop namenode
hadoop namenode -format
# starting hadoop and spark
./hadoop/sbin/start-all.sh
echo ======================CHECKING using jps===================================
echo ===============hadoop started, check for:==================================
echo ====secondary namenode, namenode, namenode mngr, resource mngr, datanode===
jps
echo ===========================================================================
./spark/sbin/start-all.sh
echo ======================CHECKING using jps======================
echo ================spark started, check for:=====================
echo ============master, worker, others will spawn with jobs=======
jps
echo ==============================================================
