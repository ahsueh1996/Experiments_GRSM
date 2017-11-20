#!/bin/bash
i=1
while [ $i -gt 0 ]; do
	/usr/lib64/sa/sa1 -S ALL 1 1 &
	sleep 10
done
