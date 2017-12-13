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

        @State(Scope.Benchmark)
        class My_State extends {
                var conf = new SparkConf()
                       		.setAppName("JMH prof: LogisticRegressionWithLBFGS")
                          .setMaster("local[*]")
                var sc = SparkContext.getOrCreate(conf)
                val inputPath = "hdfs://localhost:9000/HiBench/LR/Input"
		            // Load training data in LIBSVM format.
                var data: RDD[LabeledPoint] = sc.objectFile(inputPath).persist(StorageLevel.MEMORY_ONLY_SER)
                // Split data into training (60%) and test (40%).
                var splits = data.randomSplit(Array(0.6, 0.4), seed = 11L)
                var training = splits(0).cache()
                var test = splits(1)
                val v = Vectors
                        .dense(1.0)
                var model = new LogisticRegressionModel(v,1.0)
                @Setup(Level.Invocation)
                def doSetup() {
                        println(sc.getConf.getAll.deep.mkString("\n"))
			                  println("set up")
                }

                @TearDown(Level.Invocation)
                def doTearDown() {
			                  println("tearing down...")
                        sc.stop()
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
        	println("running...")        
		          s.model = new LogisticRegressionWithLBFGS()
                  .setNumClasses(10).run(s.training)
        }
}
