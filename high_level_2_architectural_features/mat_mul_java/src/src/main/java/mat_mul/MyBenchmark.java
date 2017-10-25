package mat_mul;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import java.util.concurrent.TimeUnit;

import java.util.Random;

@Warmup(iterations=3,time=1,timeUnit=TimeUnit.SECONDS)
@Measurement(iterations=5,time=1,timeUnit=TimeUnit.SECONDS)
@Fork(2)
@State(Scope.Benchmark)
public class MyBenchmark {
	@Param({"64","128","256","512","1024"})
	private String N_str;

	private int N;

	private int[][] shm;
	private int[][] res;
	private int i,j,k,s,aik;
	
	@Setup
	public void base() {		
		N = Integer.parseInt(N_str);
		Random rand = new Random();
		shm = new int[N][N];
		res = new int[N][N];
		for(i=0;i<N;i++){
			for(j=0;j<N;j++){
				shm[i][j] = rand.nextInt(50);
			}
		}
	}

   	@Benchmark
    	public void loop(Blackhole bh) {
		for(i=0;i<N;i++){
			for(j=0;j<N;j++){
				s=0;
				for(k=0;k<N;k++){
					s+= shm[i][k] * shm[k][j];	
				}	
				res[i][j] = s;
			}
		}
		bh.consume(res);	
    	}

	@Benchmark
	public void loop_ikj(Blackhole bh) {
		for(i=0;i<N;i++){
			for(k=0;k<N;k++){
				aik = shm[i][k];
				for(j=0;j<N;j++){
					res[i][j] += aik * shm[k][j];	
				}	
			}
		}
		bh.consume(res);	
	}

}
