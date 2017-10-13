echo "(1/3) warming up..."
perf stat -r 20 -o /dev/null bin/$1 >> /dev/null
echo "(2/3) recording..."
perf record -o perf/$1.data bin/$1 >> /dev/null
echo "(3/3) getting stat..."
perf stat -o perf/$1_stats.txt bin/$1 >> /dev/null
echo "(3/3) done"
