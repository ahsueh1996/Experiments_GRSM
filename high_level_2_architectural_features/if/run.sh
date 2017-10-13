declare -a tests=("test_empty" "test_stdio" "test_int" "test_float")
for i in ${tests[@]}
do
	sh make.sh $i
	sh perf.sh $i
done
echo "done"
