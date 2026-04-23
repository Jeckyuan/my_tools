#!/bin/bash
cnt=0

while true; do
    adb -s H6YXJVXGU4BEPVDU shell monkey --throttle 200 --ignore-crashes --ignore-timeouts --ignore-security-exceptions --kill-process-after-error -v -v 20000 2>&1 | tee ~/monkey/monkey_${cnt}.log
    sleep 1
    $((cnt++))
done
