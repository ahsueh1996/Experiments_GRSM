package mat_mul;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import java.util.concurrent.TimeUnit;

import java.util.Random;

public class MyBenchmark {
	@Param({64,128,256,512,1024})
	private int N;

	private int[][] shm;
	private int[][] res;
	private int i,j,k,s,aik;
	
	@Setup
	public void base() {
		Random rand = new Random();
		shm = new int[N][N];
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
