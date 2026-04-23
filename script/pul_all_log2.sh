#!/usr/bin/sh

echo "sh version: 0.21LLA 2025-02-07"
echo "adb killing server"
#adb kill-server

echo "adb start server as root"
adb -e root

echo "!!! Confirm adb usb is on Android !!!!"

echo "List all devices......."
adb devices

echo "Make folder......."

datetime=$(date +"%Y%m%d_%H%M%S")

mkdir -p "V5L_LOG_${datetime}/ANDROID"
mkdir -p "V5L_LOG_${datetime}/Yocto"
mkdir -p "V5L_LOG_${datetime}/Tbox"

cd "V5L_LOG_${datetime}" || exit

echo "Make subfolder ok......."

echo "adb pull Android log......."

adb -e shell 'ls /mnt/ext/logdatabr > /dev/null 2>&1 && echo "/mnt/ext/logdatabr Directory exists" || echo "/mnt/ext/logdatabr Directory does not exist"' >> ./readme.txt
adb -e pull /mnt/log/ANDROID ./ANDROID
adb -e pull /mnt/ext/logdatabr/ ./ANDROID/logdatabar
adb -e pull /data/aee_exp ./ANDROID/aee_log
adb -e pull /data/vendor/aee_exp ./ANDROID/vendor_aee_log
adb -e pull /data/tombstones ./ANDROID/tombstones
adb -e pull /data/vendor/tombstones ./ANDROID/vendor_tombstones
adb -e pull /data/anr ./ANDROID/anr
adb -e pull /data/system/dropbox ./ANDROID/dropbox
adb -e pull /data/vendor/fota/fota_log_paths.txt ./ANDROID/FOTA
adb -e pull /mnt/log/maplog ./ANDROID/maplog
adb -e pull /mnt/log/vrlog ./ANDROID/vrlog
adb -e pull /data/vendor/wifi/wlan_logs ./ANDROID/wifi
adb -e pull /data/misc/bluetooth/logs/btsnoop_hci.log ./ANDROID/btsnoop
adb -e pull /data/misc/bluedroid/btsnoop2.log ./ANDROID/btsnoop
adb -e pull /data/misc/bluedroid/btsnoop.log ./ANDROID/btsnoop
adb -e pull /data/vendor/audio ./ANDROID/audio_dump
adb -e pull /data/user_de/0/com.android.shell/files/bug ./ANDROID/dumpstate
adb -e pull /data/misc ./ANDROID/misc
adb -e pull /data/core ./ANDROID/core

echo "adb pull Yocto log......."
adb -e shell 'ls /data/vendor/share/common > /dev/null 2>&1 && echo "/data/vendor/share/common yocto Directory exists" || echo "/data/vendor/share/common yocto Directory does not exist"' >> ./readme.txt
adb -e pull /data/vendor/share/common ./Yocto/debuglogger
adb -e pull /data/vendor/share/common/log/aee_exp ./Yocto/aee_log

echo "adb pull Yocto DV log......."
adb -e shell 'ls /data/vendor/share/log > /dev/null 2>&1 && echo "/data/vendor/share/log DV yocto Directory exists" || echo "/data/vendor/share/log DV yocto Directory does not exist"' >> ./readme.txt
adb -e pull /data/vendor/share/log ./Yocto/debuglogger

echo "adb pull Tbox log......."
adb -e shell 'ls /data/vendor/share/tboxsdcard > /dev/null 2>&1 && echo "/data/vendor/share/tboxsdcard tbox Directory exists" || echo "/data/vendor/share/tboxsdcard tbox Directory does not exist"' >> ./readme.txt
adb -e pull /data/vendor/share/tboxsdcard ./Tbox/debuglogger
adb -e pull /data/vendor/share/tboxrtklog ./Tbox/tboxrtklog

echo "All logs pulled. Press Enter to exit."
read -r

