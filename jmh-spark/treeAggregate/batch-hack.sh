pd=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
td=.target/$1

if [ "$1" != "local" ] && [ "$1" != "omni" ] && [ "$1" != "packet2a" ] ; then
	echo unknown target, choose:
	echo omni, packet2a, or local
	exit
fi

if [ "$1" = "local" ] ; then
	td=.target
	f=benchmarks-${$1}.jar
else
	f=benchmarks-standalone.jar
fi

mv $pd/$td/$f /home/
rm $pd/$td/*
mv /home/$f $td

ad=$pd/archive/hacks

ap=("maxMargin/less_if" "maxMargin/less_cmp" "label/int_remove_redundant" "value/less_fcmp")
nf=("mMLessIf" "mMLessCmp" "intLabel" "lessFcmp")

for i in "${!ap[@]}"; do 
 	printf "%s\t%s\n" "${nf[$i]}" "${ap[$i]}"
	cd $pd
	cp $ad/${ap[$i]}/\#hack_src/org/apache/spark/mllib/optimization/* \#hack_src/org/apache/spark/mllib/optimization/
	
	yes 'yes' | sh hack.sh mllib/optimization $td/$f $td/${nf[$i]}
done
cd $pd
yes 'yes' | sh unhack.sh $td/$f
