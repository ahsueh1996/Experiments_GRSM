Out of disk space error:
	try using the df command to check on the disk space usage. Or use: sh df.sh <optional delay: default = 5s>

Printing to log:
	go to spark/conf/log4j.properties
	change the log level to one of the following:
		INFO 		file
		DEBUG		console
		WARN
		ERROR
	eg. logger.rootCategory=INFO, file, console
	or  logger.rootCategory=ERROR, console

Out of memory / heap:
	try increasing the -Xmx and -Xms settings. We do this automatically in the run.sh
	to check for such error vim the log.txt (default location is /) and search for WARN or GB to see the 
	progression of the memory being used up. search for "Store started" for the initial start size (is this xms? not sure).
