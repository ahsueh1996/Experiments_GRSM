declare -a tests=("base" "elif" "if_range_naive" "if_range_and")
for i in ${tests[@]}
do
	sh make.sh $i
	sh perf.sh $i
done
echo "done"
