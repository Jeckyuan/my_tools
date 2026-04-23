

logfile="/data/shutdown_test.log"

for ((i=1; i<=1000; i++)); do
	echo "========= test ${i} @ $(date +%Y-%m-%d_%H-%M-%S)==============" | tee -a ${logfile}
	nbl_vm_ctl shutdown --vmid 0
	echo "nbl_vm_ctl shutdown --vmid 0 " | tee -a ${logfile}
	sleep 5
	nbl_vm_ctl shutdown --vmid 1
	echo "nbl_vm_ctl shutdown --vmid 1 " | tee -a ${logfile}
	sleep 60
	
	nbl_vm_ctl start --vmid 0 | tee -a ${logfile}
	sleep 5
	nbl_vm_ctl start --vmid 1 | tee -a ${logfile}
	sleep 50
done



