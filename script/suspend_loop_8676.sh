interval_timer()
{
	echo timer_val 0x108000 > /proc/mtk_lpm/power/suspend_ctrl
	echo 1 > /proc/mtprintk

	while true; do
		initial_success=$(cat /sys/power/suspend_stats/success)
		echo "@@@@@@@ suspend success count: $initial_success,  device wakeup @@@@@@\n"
		echo stress > /sys/kernel/powerkey/stress
		echo "Suspend success count: $current_success" 2>&1 | tee /dev/ttyS0
		while true; do
			current_success=$(cat /sys/power/suspend_stats/success)
			if [ "$current_success" -eq "$((initial_success + 1))" ]; then
				break
			fi
			sleep 1
  		done
		echo stress > /sys/kernel/powerkey/stress
		sleep 15
	done
}

interval_timer
