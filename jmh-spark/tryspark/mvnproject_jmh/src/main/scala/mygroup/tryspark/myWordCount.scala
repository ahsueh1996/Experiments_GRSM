package mygroup.tryspark

import org.openjdk.jmh.annotations._
import scala.annotation.tailrec
import java.util.concurrent.TimeUnit

import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

@BenchmarkMode(Array(Mode.AverageTime))
@Warmup(iterations=3,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=5,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(2)
@State(Scope.Benchmark)
class SparkWordCount {
	@Benchmark
	def main() {	
		// create Spark context with Spark configuration
		val sc = new SparkContext(new SparkConf().setAppName("Spark Count"))
	    	
		// read in text file and split each document into words
    		val tokenized = sc.textFile("inputfile.txt").flatMap(_.split(" "))

    		// count the occurrence of each word
    		val wordCounts = tokenized.map((_, 1)).reduceByKey(_ + _)

    		// filter out words with fewer than threshold occurrences
    		val filtered = wordCounts.filter(_._2 >= 1)

    		// count characters
    		val charCounts = filtered.flatMap(_._1.toCharArray).map((_, 1)).reduceByKey(_ + _)

    		System.out.println(charCounts.collect().mkString(", "))
  	}
}
