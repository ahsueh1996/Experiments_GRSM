# arg1 = omni | packet2a
# arg2 = N
# we need to run the shm_mat file first to create the shared matrix file
sh make.sh shm_mat $1
./$1/bin/shm_mat $2
# the key is 17 btw
rm $1/perf/*
declare -a tests=("base" "loop" "loop_ikj")
for i in ${tests[@]}
do
	sh make.sh $i $1
	sh perf.sh $i $1 $2
done
# delete the shm
ipcrm -M 17
echo "done"
