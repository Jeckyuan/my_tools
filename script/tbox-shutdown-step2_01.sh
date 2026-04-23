#!/bin/sh

#  tbox-shutdown-step2.sh

test_count=0
while true
do 
   
    echo "nbl_vm_ctl: stop , current: $(date "+%Y-%m-%d %H:%M:%S"): $(date +%s%3N) ms"
    nbl_vm_ctl shutdown --vmid 1
    nbl_vm_ctl shutdown --vmid 0
    #vm关机的时间 包括:wdt超时是30ms+ shutdown(4秒~10秒)
    sleep 50 
    
    test_count=$((test_count+=1))
    echo "str test ${test_count} times"
    
    echo "nbl_vm_ctl: start , current: $(date "+%Y-%m-%d %H:%M:%S"):$(date +%s%3N) ms"
    nbl_vm_ctl start  --vmid 1
    nbl_vm_ctl start  --vmid 0
    # 启动vm的时间
    sleep 30
     
 
done
