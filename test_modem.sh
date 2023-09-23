#!/bin/bash

errcho(){ >&2 echo $@; }

dial_number() {
  if ! CALLID="$(
    mmcli -m any --voice-create-call "number=$NUMBER" |
    grep -Eo "Call/[0-9]+" |
    grep -oE "[0-9]+"
  )"; then
    errcho "We failed to initiate call"
    return 1
  fi
	echo $CALLID
}

print_call() {
	CALLID=$1
	echo `date`
  if ! mmcli -m any -o "$CALLID" --output-keyvalue; then
    errcho "We failed to get the call"
    return 1
  fi
}

adb devices

echo "===BEGIN DIAGNOSE===" > /dev/kmsg
adb shell 'echo "===BEGIN DIAGNOSE===" > /dev/kmsg'
echo "===Battery Voltage (uV), for PinePhone and PinePhone Pro==="
echo "Note: Errors here are normal, and no battery voltage will display at all unless the host uses an axp20x or rk818 charge controller (e.g., PinePhone, PinePhone Pro)"
cat /sys/class/power_supply/axp20x-battery/voltage_now
cat /sys/class/power_supply/rk818-battery/voltage_now
echo "===Modem State==="
mmcli -m any --output-keyvalue
echo "===CALL ATTEMPT==="
echo "CALL ATTEMPT TIME: `date "+%Y-%m-%d %H:%M:%S"`"
START=`date -d "now - 30 minutes" "+%Y-%m-%d %H:%M:%S"`
CALLID=$(dial_number)
while sleep 1 && print_call $CALLID :; do :; done
END=`date "+%Y-%m-%d %H:%M:%S"`
echo "===END DIAGNOSE===" > /dev/kmsg
adb shell 'echo "===END DIAGNOSE===" > /dev/kmsg'
echo "===ModemManager Logs==="
journalctl -u ModemManager --since="$START" --until="$END"
echo "===NetworkManager Logs==="
journalctl -u NetworkManager --since="$START" --until="$END"
echo "===OpenQTI Logs==="
adb pull /persist/openqti.log
cat openqti.log
echo "===Modem dmesg==="
adb shell 'echo Collecting dmesg... > /dev/kmsg'
adb shell dmesg

killall -9 adb
