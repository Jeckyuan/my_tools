#!/bin/bash

while true
do
	echo "suspend android"
	adb -d shell 'echo powerkey > /sys/guest_os/android/pm_state'
	sleep 8

	adb -d shell 'cat /sys/guest_os/android/pm_state'
	echo "reboot tbox"
	adb -d shell 'nbl_vm_ctl restart --vmid 1'
	sleep 15

	echo "resume android"
	adb -d shell 'echo 0 > /sys/guest_os/android/resume'

	#adbc -k
	sleep 5

	./adb_connect.sh tbox
	./adb_connect.sh and

	sleep 4

	echo "ping android:"
	adbc -t shell 'ping 193.18.5.101 -c 4'
	echo "ping tbox:"
	adbc -a root
	adbc -a shell 'ping -c 4 193.18.5.102'
	sleep 1

done
