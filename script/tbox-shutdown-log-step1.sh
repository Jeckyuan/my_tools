#!/bin/sh

journalctl  -f |grep "VmState: POWER_OFF" |tee tbox1.log

