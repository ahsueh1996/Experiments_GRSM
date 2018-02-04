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
The first stage was understanding how to run perf on simple C programs then understanding how to profile using the JMH library for a simple java program. The set up is minimal. See the readme under the perf-jmh folder for more.

The second stage was infusing JMH with Apache Spark. The setup is more elaborate. From getting the bare metal machine, run the commands found in the set up section in succession. We assume a bare metal machine. See readme under the jmh-spark folder for more.
