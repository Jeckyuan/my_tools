adb -s 127.0.0.1:7777 root
adb -s 127.0.0.1:7777 shell setenforce 0
adb -s 127.0.0.1:7777 shell "rm -rf /data/gpud_dump/"
adb -s 127.0.0.1:7777 shell "mkdir -p /data/gpud_dump/"
adb -s 127.0.0.1:7777 shell "chmod 777 /data/gpud_dump/"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.enable '1'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.folder '/data/gpud_dump/'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.process.name 'com.avatr.unityservice2'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.wsframebuffer.dump '1'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.teximage.dump '1'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.extimage.dump '1'"
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.gl.bindframebuffer.dump '1'"

adb -s 127.0.0.1:7777 shell "stop; start"
rem ## Go to the scenario where you are going to dump ...
rem  # Start to fwrite
pause
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.fwrite.enable '1'"
rem  ## Reproduce the issue ...
rem # Stop to fwrite
pause
adb -s 127.0.0.1:7777 shell "setprop vendor.debug.gpud.fwrite.enable '0'"
pause
adb -s 127.0.0.1:7777 pull /data/gpud_dump/