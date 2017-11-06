#include <stdio.h>
#include <time.h>
int main(int argc, char *argv[]) {
	srand(time(NULL));
	// please have N > 0
	int N = atoi(argv[1]);
	// offset is <= 293
	int O = atoi(argv[2]);
	// random point in square of size 1000
	int x = rand() % 1000;
	int y = rand() % 1000;
	// sqrt(1000^2/2) = 707
	int a = O;
	int b = O;
	int c = a + 707;
	int d = b + 707;
	// ideally any random point will have a 50%
	// of being in the range
	// this next int i is the workload
	int i = 0;
	int f;
	for(f=0;f<N;f++){
		i++;
	}
	return 0;
}
