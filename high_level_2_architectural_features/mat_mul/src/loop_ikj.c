#include <stdlib.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
	int N = atoi(argv[1]);
	key_t key = 17;
	int shmid;
	int (*shm)[N];

	shmid = shmget(key, sizeof(int[N][N]),0666);
	if (shmid == -1) { exit(1);}
	shm = shmat(shmid,0,0);
	if (shm == (void*) -1) { exit(1);}
	
	int i,j,k,aik;
	int res[N][N];
	for(i=0;i<N;i++){
		for(k=0;k<N;k++){
			aik = shm[i][k];
			for(j=0;j<N;j++){
				res[i][j] += aik * shm[k][j];	
			}	
		}
	}	
	return 0;
}
