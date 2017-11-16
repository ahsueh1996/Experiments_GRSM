package grsm

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit
import org.openjdk.jmh.infra.Blackhole

import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}

import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD

//import org.apache.spark.rdd.RDD
//import org.apache.spark.SparkContext

// This static main method might be needed for spark
//object Main {
//	def main(args: Array[String]) {	
//	}
//}

@BenchmarkMode(Array(Mode.AverageTime))
@Warmup(iterations=3,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=5,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(2)
@State(Scope.Benchmark)
class Benchmarks {
	
	@Benchmark
	def HiBench_LR() {
		// Path taken from HiBench functions/workload-function.sh
    		var inputPath = "hdfs://localhost:9000/HiBench/LR/Input"

    		val conf = new SparkConf()
			.setAppName("JMH prof: LogisticRegressionWithLBFGS")
			.setMaster("local[*]")
    		val sc = new SparkContext(conf)

    		// $example on$
    		// Load training data in LIBSVM format.
    		val data: RDD[LabeledPoint] = sc.objectFile(inputPath)

    		// Split data into training (60%) and test (40%).
    		val splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
    		val training = splits(0).cache()
    		val test = splits(1)

    		// Run training algorithm to build the model
    		val model = new LogisticRegressionWithLBFGS()
      				.setNumClasses(10)
      				.run(training)

    		// Compute raw scores on the test set.
    		val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
      			val prediction = model.predict(features)
	      		(prediction, label)
    		}

    		val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
    		println(s"Accuracy = $accuracy")

    		sc.stop()
	}
}
