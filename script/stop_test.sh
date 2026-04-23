#!/bin/bash

[ $# -ne 2 ] && { echo "Usage: ./stop_test.sh {ADB_DEVICE_NAME} {TEST_LOOPS}"; exit 1; }

adbdev=$1
loops=$2

logfile="./stop_test.log"
monkeylog="./monkey.log"

yadb="adb -s "${adbdev}" wait-for-device"

${yadb}

echo "Start android monkey test" | tee ${logfile}
./monkey.sh 2>&1 > ${monkeylog} &
mpid=$!
echo $mpid
sleep 5

for i in `seq ${loops}`; do
	echo "========= test ${i} @ $(date +%Y-%m-%d_%H-%M-%S)==============" | tee -a ${logfile}
	${yadb} shell "nbl_vm_ctl stop --vmid 0; nbl_vm_ctl stop --vmid 1" | tee -a ${logfile}
	${yadb} shell "nbl_vm_ctl start --vmid 0; nbl_vm_ctl start --vmid 1" | tee -a ${logfile}
	stime=$(( ${RANDOM} % 60 ))
	echo "sleep ${stime}s" | tee -a ${logfile}
	sleep ${stime}
	${yadb} shell "ls /data/aee_exp/db.* 2> /dev/null" | tee -a ${logfile}
done

kill $mpid

