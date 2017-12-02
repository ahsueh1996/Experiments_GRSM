pd=/home/hsuehku1/Experiments_GRSM/jmh-spark/treeAggregate
td=$pd/.target/$1

if [ "$1" != "local" ] && [ "$1" != "omni" ] && [ "$1" != "packet2a" ] ; then
	echo unknown target, choose:
	echo omni, packet2a, or local
	exit
fi

if [ "$1" = "local" ] ; then
	td=$pd/.target
	f=benchmarks-${$1}.jar
else
	f=benchmarks-standalone.jar
fi

mv $td/$f /home/
rm $td/*
mv /home/$f $td
cd $pd

ad=$pd/archive/hacks

ap=("maxMargin/less_if" "maxMargin/less_cmp" "label/int_remove_redundant" "value/less_fcmp")
nf=("mMLessIf" "mMLessCmp" "intLabel" "lessFcmp")

for i in "${!ap[@]}"; do 
 	printf "%s\t%s\n" "${nf[$i]}" "${ap[$i]}"
	cp $ad/${ap[$i]}/\#hack_src/org/apache/spark/mllib/optimization/* \#hack_src/org/apache/spark/mllib/optimization/
	sh hack.sh mllib/optimization $td/$f $td/${n[f$i]}
done

sh unhack.sh $td/$f
