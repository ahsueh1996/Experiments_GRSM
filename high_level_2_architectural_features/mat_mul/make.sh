#$0 is the script name, $1 is the first arg, $n is the nth arg.
echo "(1/2) writing assem to ass/$1.s ..."
gcc src/$1.c -S -O0 -o $2/ass/$1.s
echo "(2/2) writing binary to bin/$1 ...."
gcc src/$1.c -O0 -o $2/bin/$1
echo "(2/2) done"
