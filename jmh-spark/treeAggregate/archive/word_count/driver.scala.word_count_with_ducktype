package grsm

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit
import org.openjdk.jmh.infra.Blackhole

import org.apache.spark.sql.SparkSession
import org.apache.spark.SparkContext
import org.apache.spark.rdd.RDD

// This static main method might be needed for spark
//object Main {
//	def main(args: Array[String]) {	
//	}
//}


class Dummy {
	def textFile(path: String, minPartitions: Int): RDD = {
		return null
	}	
}

@BenchmarkMode(Array(Mode.AverageTime))
@Warmup(iterations=3,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=5,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(2)
@State(Scope.Benchmark)
class Benchmarks {
	
	var sc : {def
textFile(path: String, minPartitions: Int): RDD} = new Dummy()

	@Setup
	def setup() {
		val sess = SparkSession.builder.master("local[4]")
              	               .appName("dummy")
                       	       .config("spark.ui.enabled", "false")
                     	       .getOrCreate
		sc = sess.sparkContext
	}

	@Benchmark
	def run() {
//		val sess = SparkSession.builder.master("local[4]")
//              	               .appName("dummy")
//                       	       .config("spark.ui.enabled", "false")
 //                      	       .getOrCreate
//		val sc = sess.sparkContext
		// read in text file and split each document into words
    		val tokenized = sc.textFile("inputfile.txt",2).flatMap(_.split(" "))

    		// count the occurrence of each word
    		val wordCounts = tokenized.map((_, 1)).reduceByKey(_ + _)

    		// filter out words with fewer than threshold occurrences
    		val filtered = wordCounts.filter(_._2 >= 1)

    		// count characters
    		val charCounts = filtered.flatMap(_._1.toCharArray).map((_, 1)).reduceByKey(_ + _)

    		System.out.println(charCounts.collect().mkString(", "))
	}
}
