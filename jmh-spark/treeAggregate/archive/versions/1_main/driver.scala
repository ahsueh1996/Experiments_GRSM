package grsm

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit
import org.openjdk.jmh.infra.Blackhole

import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}

import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD

object Benchmarks {
	@State(Scope.Benchmark)
	class My_State {
		//.setMaster("local[*]")
		//.setMaster("spark://147.75.202.66:7077")
		//.setMaster("spark://142.150.237.146:7077")
    		val conf = new SparkConf()
			.setAppName("JMH prof: LogisticRegressionWithLBFGS")
			.setMaster("local[*]")
		
			//.set("spark.network.timeout", "600s")
			//.setJars(Array("/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/.target/tmp-benchmarks.jar"))
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
		
		var model = new LogisticRegressionWithLBFGS()
		
		@Setup(Level.Trial)
		def doSetup() {
			println("\n")
			println(conf.getAll.deep.mkString("\n"))
		}
		
		@TearDown(Level.Trial)
		def doTearDown() {
			// Compute raw scores on the test set.
			val predictionAndLabels = s.test.map { case LabeledPoint(label, features) =>
				val prediction = model.predict(features)
				(prediction, label)
			}
			val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
			println(s"Accuracy = $accuracy")
			// because we stop the sc here, we should only have 1 fork
			sc.stop()
		}
	}
}

@Warmup(iterations=0,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=1,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(1)
class Benchmarks {
	@Benchmark
	@Warmup(iterations = 1, batchSize = 1)
	@Measurement(iterations = 9, batchSize = 1)
	@BenchmarkMode(Mode.SingleShotTime)
	def singleshot_LR(s: Benchmarks.My_State, bh: Blackhole) {
    		// Run training algorithm to build the model
		// btw, what if numclasses = 2?
		s.model.setNumClasses(10).run(s.training)
		bh.consume(s.model)
	}
	
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def Multinomial_LR(s: Benchmarks.My_State, bh: Blackhole) {
    		// Run training algorithm to build the model
		// btw, what if numclasses = 2?
		s.model.setNumClasses(10).run(s.training)
		bh.consume(s.model)
	}
}
