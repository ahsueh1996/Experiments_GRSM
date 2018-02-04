The second stage was infusing JMH with Apache Spark. The setup is more elaborate. From getting the bare metal machine, run the commands found in the set up section in succession. We assume a bare metal machine. See setup folder for more.

Using a tuning script we varied the spark configurations until 150k LR performed the best and used the optimal settings in our profiling runs. (Take away 1: speed up gains through spark tuning.) x86 and ARM gave differnt optimal settings primarily due to the different "number of cores" count on the machines. (Take away 2: local[*] vs [n] vs spark://<url>:7077, and relation to settings.)

Because spark standalone creates multiple JVMs, we don't think JMH could actually trace and profile the workload properly (perfasm couldn't find any hottest region above a 10% workload). For that reason we used the local mode with n= (optimal settings found), to conduct profiling.
