#!/bin/bash

func_adb_connect_sos() {
	echo "start connect sos adb"
	adb disconnect 127.0.0.1:7665
	adb -d forward tcp:7665 tcp:6665
	adb connect 127.0.0.1:7665
	echo "end connect sos adb"
}

func_adb_connect_tbox_uos() {
	echo "start connect uos tbox adb"
	adb disconnect 127.0.0.1:7667
	adb -d forward tcp:7667 tcp:6667
	adb connect 127.0.0.1:7667
	echo "end connect uos tbox adb"
}

func_adb_connect_and_uos() {
	echo "start connect uos android adb"
	adb disconnect 127.0.0.1:7666
	adb -d forward tcp:7666 tcp:6666
    adb connect 127.0.0.1:7666
	adb -s 127.0.0.1:7666 root;adb connect 127.0.0.1:7666
	echo "end connect uos android adb"
}

if [ $# != 1 ];then
	echo "./adb_connect.sh [sos|tbox|and]"
	exit -1
else
	if [ $1 == "sos" ];then
		func_adb_connect_sos
		exit 0
	elif [ $1 == "tbox" ];then
		func_adb_connect_tbox_uos
		exit 0
	elif [ $1 == "and" ];then
		func_adb_connect_and_uos
		exit 0
	else
		echo "input parameter is invalid"
		exit 1
	fi

fi

