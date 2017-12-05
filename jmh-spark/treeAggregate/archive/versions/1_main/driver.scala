package grsm

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit
import org.openjdk.jmh.infra.Blackhole

import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}

import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD

@Warmup(iterations=2,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=3,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(1)
class Benchmarks {
	
	@State(Scope.Benchmark)
	object My_State {
    		val conf = new SparkConf()
			.setAppName("JMH prof: LogisticRegressionWithLBFGS")
			.setMaster("spark://147.75.202.66:7077")
			.set("spark.network.timeout", "600s")
			.setJars(Array("/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/.target/tmp-benchmarks.jar"))
    		val sc = new SparkContext(conf)
		
		// Path taken from HiBench functions/workload-function.sh
    		var inputPath = "hdfs://localhost:9000/HiBench/LR/Input"

    		// $example on$
    		// Load training data in LIBSVM format.
    		val data: RDD[LabeledPoint] = sc.objectFile(inputPath)

    		// Split data into training (60%) and test (40%).
    		val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    		val training = splits(0).cache()
    		val test = splits(1)
		
		@Setup(Level.Trial)
		def doSetup() {
			println("\n")
			println(conf.getAll.deep.mkString("\n"))
		}
	}
	
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def HiBench_LR(s: My_State) {

    		// Run training algorithm to build the model
    	
		val model = new LogisticRegressionWithLBFGS()
      				.setNumClasses(10)
      				.run(s.training)

    		// Compute raw scores on the test set.
    		val predictionAndLabels = s.test.map { case LabeledPoint(label, features) =>
      			val prediction = model.predict(features)
	      		(prediction, label)
    		}

    		val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
    		println(s"Accuracy = $accuracy")
	}
}
