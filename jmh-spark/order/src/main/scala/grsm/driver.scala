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
		var f = 1.0
		var i = 1
		var bf = 9999.999999999999999999999999
		var bi = 2140000

		@Setup(Level.Trial)
		def doSetup() {
		}
	}
}

@Warmup(iterations=3,time=500,timeUnit=TimeUnit.MICROSECONDS)
@Measurement(iterations=10,time=500,timeUnit=TimeUnit.MICROSECONDS)
@Fork(10)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
class Benchmarks {	
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fcmp(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.f > 0.0) {
			bh.consume(s.f)
		}			 
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fcmp_big(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.bf > 0.0) {
			bh.consume(s.bf)
		}			 
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fcmp_w_int(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.f > 1) {
			bh.consume(s.f)
		}			 
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def cmp(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.i > 1) {
			bh.consume(s.i)
		}			 
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def cmp_big(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.bi > 1) {
			bh.consume(s.bi)
		}			 
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def cmp_w_flt(s: Benchmarks.My_State, bh: Blackhole) {
		if (s.i > 1.0) {
			bh.consume(s.i)
		}			 
	}	
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fdiv(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.f/2.0)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fmul(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.f*2.0)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fadd(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.f+2.0)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fadd_w_int(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.f+2)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def fdiv_big(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.bf/3.14447)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def div(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.i/2)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def mul(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.i*2)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def add(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.i+2)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def add_w_flt(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.i+2.00)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def div_big(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.bi/13)
	}
	@Benchmark
	@BenchmarkMode(Array(Mode.AverageTime))
	def to_int(s: Benchmarks.My_State, bh: Blackhole) {
		bh.consume(s.f.toInt)
	}
}
