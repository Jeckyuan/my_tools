#!/bin/sh

#  journalctl  -f |grep "VmState: POWER_OFF" |tee tbox1.log

test_count=0
while true
do 
   
    echo "echo 5:0 > /proc/aed/generate-wdt, current: $(date "+%Y-%m-%d %H:%M:%S")"
    echo 5:0 > /proc/aed/generate-wdt
    #vm关机的时间
    sleep 40
   
 
done
