# arg1 = omni | packet2a
# arg2 = N size of range
# arg3 = O offset
rm $1/perf/*
#declare -a tests=("base" "elif" "if_range_naive" "if_range_and")
declare -a tests=("base_r" "elif_r" "if_range_naive_r" "if_range_and_r")
for i in ${tests[@]}
do
	sleep 1
	sh make.sh $i $1
	sh perf.sh $i $1 $2 $3
done
echo "done"
