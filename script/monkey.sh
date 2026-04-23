#!/bin/sh


while true; do
   monkey --throttle 300 50000 --pct-touch 40 --pct-motion 30 --pct-pinchzoom 5 --pct-syskeys 10 --pct-appswitch 10 --pct-flip 5 -s 0 --ignore-crashes --ignore-timeouts --ignore-native-crashes --pkg-whitelist-file /data/whitelist.txt  -v -v -v DATE= date  #sleep 1 count=$(($count+1)) done 
done
