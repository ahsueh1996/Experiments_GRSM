#$0 is the script name, $1 is the first arg, $n is the nth arg.
echo "(1/3) writing assem to ass/$1.s ..."
gcc src/$1.c -O0 -S -o $2/ass/$1.s
echo "(2/3) writing binary to bin/$1 ...."
gcc src/$1.c -O0 -o $2/bin/$1
echo "(3/3) writing optimizations?"
echo "(3/3) done"
