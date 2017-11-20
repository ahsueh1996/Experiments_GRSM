references:
	I try to use _ when I'm naming a folder based on the directory of the contents.
	hibench-lr-src: 
		contains the original sources from hibench. We changed the LogisticRegression.scala file to make our driver
	report_conf_sparkbecnh:
		the config files that hibench inputs as property files. We got this from sebastian's outputs and copied it out as myspark.conf because the
		report folder is not always populated

versions:
	There are three main dimensions to the versions:
	- with or without JMH setup/tear down. without the JMH setup/teardown we will get a const error associated with initializing spark context
	- the spark URL, unfortunately we can't use the dynamic injection of URL with the JMH infused drivers (why? I don't know)
	- the number of forks, warmups and iterations
	
	we will deliminate with ":"
	0:<IP>:211 = no JMH setup/teardown, using IP as the spark master,2 forks 1 warmup 1 iteration
	1:omni[*]:235 = yes JMH setup/teardown, using local master @ omni with as many threads as cores, 2 forks, 3 warmups,5 iterations

