#!/bin/bash

[ $# -ne 2 ] && { echo "Usage: ./reboot_tbox.sh {ADB_DEVICE_NAME} {TEST_LOOPS}"; exit 1; }

adbdev=$1
loops=$2
TimeStamp=$(date +"%Y%m%d_%H%M%S")
logfile="./reboot_tbox_${TimeStamp}.log"

#yadb="adb -s "${adbdev}" wait-for-device"
#
#${yadb}
#
#mpid=$!
#echo $mpid
sleep 5

for i in `seq ${loops}`; do
	echo "========= test ${i} @ $(date +%Y-%m-%d_%H-%M-%S)==============" | tee -a ${logfile}
	${yadb} shell "nbl_vm_ctl restart --vmid 1 " | tee -a ${logfile}
	sleep 100
	${yadb} shell "nbl_vm_ctl vminfo " | tee -a ${logfile}
done

#kill $mpid
