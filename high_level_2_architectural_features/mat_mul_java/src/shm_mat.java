#include <stdio.h>
#include <sys/shm.h>
#include <sys/ipc.h>
#include <stdlib.h>

int main (int argc, char* argv[]) {
	int N = atoi(argv[1]);
	key_t key;
	int shmid;
	int (*shm)[N];

	key = 17;
	shmid = shmget(key, sizeof(int[N][N]),IPC_CREAT|0666);
	if (shmid == -1) { exit(1);}
	shm = shmat(shmid,0,0);
	if (shm == (void*) -1) { exit(1);}
	
	int i,j;
	for (i=0;i<N;i++) {
		for (j=0;j<N;j++) {
			shm[i][j] = rand()%256;
		}
	}	
	return 0;
}
