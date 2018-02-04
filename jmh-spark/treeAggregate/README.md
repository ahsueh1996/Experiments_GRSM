# Build the mvn project using:
	
	mvn clean package

This will put a benckmarks.jar into the target folder. This is the jar file we submit to spark
During the build, a copy of all the dependicies will also be copied to the target/lib/ folder (this is for altering spark libs)

# Build your altered spark src from \#hack_src:
	
	scalac -classpath "target/lib/*" -d \#hack_lib/ \#hack_src/org/apache/spark/mllib/optimization/LBFGS.scala

The above example builds LBFGS.scala and puts it in \#hack_lib. Next we will insert the compiled classes and
overwrite the .class files already in the benchmarks.jar

# Doing the "hack":
	
	jar uf benchmarks.jar -C ../#hack_lib ../#hack_lib/org/apache/spark/mllib/optimization/LBFGS.scala
		
This hack will only alter your own spark dependencies that benchmarks.jar contains. If you want to actually change the library that is installed in your system, you have to locate the jar containing the package that you altered and use that as the new jar target.
I located the jar by looking at what the spark submit function built as the spark jar directory.
	
	SPARK_JARS_DIR="${SPARK_HOME}/assembly/target/scala-$SPARK_SCALA_VERSION/jars" ln 42 from spark/bin/spark-class
	
then you can view a jar content with
		
	jar tvf jarfile.jar | grep "the class you are looking for"
		
# Viewing jobs and debug tips:

+ Set log4j to only log the errors, read the error message...
+ Set log4j to write to a log file. I think this is the executor log people talk about online. gives more detailed messages
+ With the job running, go to the 8080 port to get the "webUI." It'll give you some basic summary about what is running and what completed. The webUI is created everytime you run the start.sh
+ Use the spark history server? Only works with yarn I think
+ I advise understanding better how spark jobs really look, including details about the data partitions and such.


