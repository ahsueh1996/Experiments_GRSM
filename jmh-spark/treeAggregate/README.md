Build the mvn project using:
	
		mvn clean package

	This will put a benckmarks.jar into the target folder. This is the jar file we submit to spark
	During the build, a copy of all the dependicies will also be copied to the lib/ folder

Build your altered spark src from #hack_src:
	
		scalac -classpath "target/lib/*" -d \#hack_lib/ \#hack_src/org/apache/spark/mllib/optimization/LBFGS.scala

	The above example buils LBFGS.scala and puts it in the #hack_lib. Next we will insert the compiled classes and
	overwrite the .class files already in the benchmarks.jar

Doing the #hack:
	
		jar -xf

