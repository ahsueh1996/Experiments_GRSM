package grsm

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit
import org.openjdk.jmh.infra.Blackhole

import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}

import org.apache.spark.mllib.classification.LogisticRegressionWithLBFGS
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD
import org.apache.spark.mllib.classification.LogisticRegressionModel

import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.storage.StorageLevel

object Benchmarks {

        @State(Scope.Thread)
        class My_State extends {
                //.setMaster("local[*]")
                //.setMaster("spark://147.75.202.66:7077")
                //.setMaster("spark://142.150.237.146:7077")
                var conf = new SparkConf()
                       		.setAppName("JMH prof: LogisticRegressionWithLBFGS")
                		.setMaster("spark://142.150.237.146:7077")
                      		.set("spark.network.timeout", "600s")
                        	.setJars(Array("/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate/.target/tmp-benchmarks.jar"))
                var sc = SparkContext.getOrCreate(conf)

                // Path taken from HiBench functions/workload-function.sh
                val inputPath = "hdfs://localhost:9000/HiBench/LR/Input"

                
		// Load training data in LIBSVM format.
                var data: RDD[LabeledPoint] = sc.objectFile(inputPath).persist(StorageLevel.MEMORY_ONLY)

                // Split data into training (60%) and test (40%).
                var splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
                var training = splits(0).cache()
                var test = splits(1)
                val v = Vectors
                        .dense(1.0)
                var model = new LogisticRegressionModel(v,1.0)

                @Setup(Level.Invocation)
                def doSetup() {
			println("setting up...")
                        println(sc.getConf.getAll.deep.mkString("\n"))
		
                	data = sc.objectFile(inputPath).persist(StorageLevel.MEMORY_ONLY)

        	        splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
               	 	training = splits(0).cache()
               		test = splits(1)
			
			println("...")
			println(sc.getRDDStorageInfo.deep.mkString("\n"))
			println("set up")
                }

                @TearDown(Level.Invocation)
                def doTearDown() {
			println("tearing down...")
                        //sc.stop()
			println("toredown")
                }
        }
}

class Benchmarks {
        @Benchmark
        @Fork(1)
        @Warmup(iterations = 1, batchSize = 1)
        @Measurement(iterations = 5, batchSize = 1)
        @BenchmarkMode(Array(Mode.SingleShotTime))
        def Multinomial_LR(s: Benchmarks.My_State) {
		s.sc = SparkContext.getOrCreate(s.conf)

		// Run training algorithm to build the model
                var LR = new LogisticRegressionWithLBFGS()
		LR.setNumClasses(10)
		s.model = LR.run(s.training)


		// Compute raw scores on the test set.
    		val predictionAndLabels = s.test.map { case LabeledPoint(label, features) =>
      			val prediction = s.model.predict(features)
	      		(prediction, label)
    		}

    		val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
    		println(s"Accuracy = $accuracy")
		
        }
}
