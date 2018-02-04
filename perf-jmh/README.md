The first stage was understanding how to run perf on simple C programs then understanding how to profile using the JMH library for a simple java program. The set up is minimal:
 	yum install git
	yum install mercurial
	yum group install "Development Tools"
	yum install perf
	yum install maven
	yum install java-1.8.0-openjdk-devel
  git clone https://github.com/ahsueh1996/Experiments_GRSM.git
  
Additionally for ARM, copy the aarch64 libarary to enable perfasm print outs:
	cp ~/Experiments_GRSM/perf-jmh/mat_mul_java/hsdis-aarch64.so /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-1.b12.el7_4.aarch64/jre/lib/aarch64/server/.
  
Then just sh run.sh to collect data.
