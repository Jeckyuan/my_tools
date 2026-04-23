

logfile="/data/shutdown_test.log"

for ((i=1; i<=1000; i++)); do
	echo "========= test ${i} @ $(date +%Y-%m-%d_%H-%M-%S)==============" | tee -a ${logfile}
	nbl_vm_ctl shutdown --vmid 0
	echo "nbl_vm_ctl shutdown --vmid 0 " | tee -a ${logfile}
	sleep 50
	
	nbl_vm_ctl start --vmid 0 | tee -a ${logfile}
	sleep 50
done



