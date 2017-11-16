# Experiments_GRSM
This project includes experiments using the following languages/code libraries:
	+ C
	+ Java
  + Scala
  + Spark (in conjunction with Hadoop)
We use profiling tools:
  + Perf
  + JMH
We use a local x86 machine (Centos6) called omni and a remote machine (Centos7) ARM machine called packet2a (from https://www.packet.net/; Type 2A Centos7) to conduct the experiments.
  
# Method
The first stage was understanding how to profile using the JMH library for a simple java code after understanding how to run perf on simple C programs. The set up is minimal:
 	yum install git
	yum install mercurial
	yum group install "Development Tools"
	yum install perf
	yum install maven
	yum install java-1.8.0-openjdk-devel
  git clone https://github.com/ahsueh1996/Experiments_GRSM.git
  
For ARM, copy the aarch64 libarary to enable perfasm print outs:
	cp ~/Experiments_GRSM/perf-jmh/mat_mul_java/hsdis-aarch64.so /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-1.b12.el7_4.aarch64/jre/lib/aarch64/server/.
  
Then just sh run.sh to collect data.

The second stage was infusing JMH with Apache Spark. The setup is more elaborate. From getting the bare metal machine, run the following commands in succession:
  + ssh-keygen -t rsa ; ssh root@localhost mkdir -p .ssh ; cat /root/.ssh/id_rsa.pub | ssh root@localhost 'cat >> /root/.ssh/authorized_keys' ; echo ; echo ; echo ; echo ======================= ; echo you may leave now for about an hour, installing dependencies ; echo ctrl+tap a + tap d to detach from screen ; echo ========================== ; sleep 5 ;  yes 'yes' | yum install git ; yes 'yes' | yum install mercurial ; yes 'yes' | yum group install "Development Tools" ; yes 'yes' | yum install perf ; mkdir -p /home/hsuehku1 ; cd /home/hsuehku1 ; git clone https://github.com/ahsueh1996/Experiments_GRSM.git ; mkdir -p /home/hibench-output ; mkdir -p /CMC/kmiecseb ; cd /CMC/kmiecseb

  + sh /home/hsuehku1/Experiments_GRSM/jmh-spark/packet_setup_1.sh ; source ~/.bashrc ; echo ; echo ; echo =========================== ; echo testing java and mvn ; sleep (3) ; java ; echo ; echo ; echo =========================== ; sleep (3) ; mvn

  + sh /home/hsuehku1/Experiments_GRSM/jmh-spark/packet_setup_2.sh ; echo ;
echo ; echo ; echo ===========================; echo scroll up to see 4 tests passed 

  + cp /home/hsuehku1/Experiments_GRSM/jmh-spark/spark-src/CMC/kmiecseb/hadoop /CMC/kmiecseb/. -r ; sh /home/hsuehku1/Experiments_GRSM/jmh-spark/packet_setup_3.sh ;

  + cp /home/hsuehku1/Experiments_GRSM/jmh-spark/spark-src/CMC/kmiecseb/spark /CMC/kmiecseb/. -r ; sh /home/hsuehku1/Experiments_GRSM/jmh-spark/packet_setup_4.sh ; echo ; echo ; echo ; echo ====================== ; echo attempting to start spark shell, see the spark logo then ctrl-c to quit ; sh /CMC/kmiecseb/spark/sbin/start-all.sh ; /CMC/kmiecseb/spark/bin/spark-shell 

  + cp /home/hsuehku1/Experiments_GRSM/jmh-spark/spark-src/CMC/kmiecseb/HiBench/ /CMC/kmiecseb/. -r ; yes 'Y' | sh /home/hsuehku1/Experiments_GRSM/jmh-spark/packet_setup_5.sh

  + export SPARK_HOME=/CMC/kmiecseb/spark ; export SPARK_MASTER=spark://$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'):7077 ; cp /CMC/kmiecseb/HiBench/bin/* /bin/. ; cp /home/hsuehku1/Experiments_GRSM/jmh-spark/spark-src/CMC/kmiecseb/reset.sh /CMC/kmiecseb/reset.sh ; cp /home/hsuehku1/Experiments_GRSM/perf-jmh/mat_mul_java/hsdis-aarch64.so /CMC/kmiecseb/jdk8u-server-release-1708/jre/lib/aarch64/server/.  

  + sh /CMC/kmiecseb/reset.sh ; echo ====================; echo hdfs test ; echo ========================== ; hdfs dfs -ls / ; sh /CMC/kmiecseb/HiBench/bin/workloads/ml/lr/prepare/prepare.sh hdfs://localhost9000/HiBench/LR/Input 1000 3000 ; echo ; echo ; echo ; echo ========================== ; hdfs dfs -ls /HiBench/LR/ ; echo ======================= ; echo should see populated hdfs ; echo ; echo ; echo ; echo ================= ; echo done ; echo ========================


