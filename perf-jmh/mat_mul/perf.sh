echo "(1/3) warming up..."
perf stat -r 2 -o /dev/null $2/bin/$1 $3 >> /dev/null
echo "(2/3) recording..."
perf record -o $2/perf/$1.data $2/bin/$1 $3 >> /dev/null
echo "(3/3) getting stat..."
perf stat -d -o $2/perf/$1_stats.txt $2/bin/$1 $3 >> /dev/null
echo "(3/3) done"
