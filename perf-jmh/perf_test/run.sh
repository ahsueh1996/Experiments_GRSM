declare -a tests=("base" "stdio" "int" "float")
for i in ${tests[@]}
do
	sh make.sh $i $1
	sh perf.sh $i $1
done
echo "done"
