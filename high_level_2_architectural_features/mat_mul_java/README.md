1) sh run.sh <machine> , if no machine specified, the output text files will be created in the same folder as run.sh
2) all output gets stored in the correspondiing folders and changes to the params/script are over written
3) if no assembly prints, check out the JVM invoker path in the print out corresponding to the -prof perfasm run go to the directory, then cd ../lib/<uarch: amd64 or aarch64>/server and paste the correct disassembler in there
4) you will need maven to do the build but if the build is already done and there is a target/benchmarks.jar then the rest of the code will still execute fine
