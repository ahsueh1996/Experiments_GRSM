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

The second stage was infusing JMH with Apache Spark. The setup is more elaborate. From getting the bare metal machine, run the commands found in the set up section in succession. We assume a bear metal machine.

Using a tuning script we varied the spark configurations until 150k LR performed the best and used the optimal settings in our profiling runs. (Take away 1: speed up gains through spark tuning.) x86 and ARM gave differnt optimal settings primarily due to the different "number of cores" count on the machines. (Take away 2: local[*] vs [n] vs spark://<url>:7077, and relation to settings.)

Because spark standalone creates multiple JVMs, we don't think JMH could actually trace and profile the workload properly (perfasm couldn't find any hottest region above a 10% workload). For that reason we used the local mode with n= (optimal settings found), to conduct profiling. 

Top 3 hottest regions found were:


