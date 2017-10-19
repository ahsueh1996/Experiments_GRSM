#include <stdio.h>
#include <time.h>
int main(int argc, char *argv[]) {
	srand(time(NULL));
	// please have N > 0
	int N = atoi(argv[1]);
	// offset is <= 293
	int O = atoi(argv[2]);
	// random point in square of size 1000
	int x = rand() % 1000 * N;
	int y = rand() % 1000 * N;
	// sqrt(1000^2/2) = 707
	int a = O * N;
	int b = O * N;
	int c = a + 707 * N;
	int d = b + 707 * N;
	// ideally any random point will have a 50%
	// of being in the range
	return 0;
}
