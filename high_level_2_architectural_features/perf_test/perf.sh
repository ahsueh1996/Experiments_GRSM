perf record -o perf/$1.data bin/$1
perf stat -o perf/$1_stats.txt bin/$1
