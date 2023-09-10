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

enable_adb() {
  if ! SMSID="$(
    mmcli -m any --messaging-create-sms="text='enable adb',number='+223344556677'" |
    grep -Eo "SMS/[0-9]+" |
    grep -oE "[0-9]+"
  )"; then
    errcho "We failed to enable adb"
    return 1
  fi
}

disable_adb() {
  if ! SMSID="$(
    mmcli -m any --messaging-create-sms="text='disable adb',number='+223344556677'" |
    grep -Eo "SMS/[0-9]+" |
    grep -oE "[0-9]+"
  )"; then
    errcho "We failed to enable adb"
    return 1
  fi
	sleep 1
}

enable_adb

echo "===Modem State==="
mmcli -m any --output-keyvalue
echo "===CALL ATTEMPT==="
echo "CALL ATTEMPT TIME: `date "+%Y-%m-%d %H:%M:%S"`"
START=`date -d "now - 30 minutes" "+%Y-%m-%d %H:%M:%S"`
CALLID=$(dial_number)
while sleep 1 && print_call $CALLID :; do :; done
END=`date "+%Y-%m-%d %H:%M:%S"`
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

disable_adb
