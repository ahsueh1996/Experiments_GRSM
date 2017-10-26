# arg1 = omni | packet2a
cd src
#mvn clean install
echo "=================================================="
echo "running normal"
#java -jar target/benchmarks.jar | tee ../$1/normal.txt
echo "=================================================="
echo "running perfnorm"
#java -jar target/benchmarks.jar -prof perfnorm | tee ../$1/perfnorm.txt
echo "=================================================="
echo "running assem"
java -XX:+UnlockDiagnosticVMOptions -XX:CompileCommand=print,MyBenchmark -jar target/benchmarks.jar -prof perfasm | tee ../$1/perfasm.txt
echo "done"
