pd=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
td=.target/$1

if [ "$1" != "local" ] && [ "$1" != "omni" ] && [ "$1" != "packet2a" ] ; then
	echo unknown target, choose:
	echo omni, packet2a, or local
	exit
fi

if [ "$1" = "local" ] ; then
	td=.target
	f=benchmarks-local.jar
else
	f=benchmarks-standalone.jar
fi

echo check check check!!!!!! enter if correct, abort else
read -p "$pd/$td/$f /home/hsuehku1"
mv $pd/$td/$f /home/hsuehku1
rm $pd/$td/*
mv /home/hsuehku1/$f $td

ad=$pd/archive/hacks

ap=("maxMargin/less_if" "maxMargin/less_cmp" "label/int" "label/less" "value/less_fcmp" "conglomerate")
nf=("mMLessIf" "mMLessCmp" "intLabel" "lessLabel" "lessFcmp" "conglomerate")

for i in "${!ap[@]}"; do 
 	printf "%s\t%s\n" "${nf[$i]}" "${ap[$i]}"
	cd $pd
	cp $ad/${ap[$i]}/\#hack_src/org/apache/spark/mllib/optimization/* \#hack_src/org/apache/spark/mllib/optimization/
	if [ "$1" = "local" ] ; then	
		yes 'yes' | sh hack.sh mllib/optimization $td/$f $td/benchmarks-${nf[$i]}-local.jar
	else
		yes 'yes' | sh hack.sh mllib/optimization $td/$f $td/benchmarks-${nf[$i]}-standalone.jar
	fi	
done
cd $pd
yes 'yes' | sh unhack.sh $td/$f
