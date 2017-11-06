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
	int i = 0;
	int f;
	
	for(f=0;f<N;f++){
		if (x > a) {
			i++;
		} else if (y < b) {
			i--;
		}
	}
	return 0;
}
