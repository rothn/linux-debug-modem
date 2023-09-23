Before using, enable ADB on the modem like:
```
sudo ./enable_adb.sh
```

Then, use like so to diagnose issues:

```
sudo NUMBER=+15555555555 ./test_modem.sh > modem_test.log
```

Warning: If your distro (e.g., Mobian) does not provide a symlink or modem device at /dev/EG25.AT, you'll need to provide one.
Example for PinePhone and PinePhone Pro:
```
sudo ln -s /dev/ttyUSB2 /dev/EG25.AT
```
_By default, and unless you have a USB serial converter connected to the OTG port in the PP/PPP or there is unexpected behavior in the kernel, the modem's USB AT port will always be ttyUSB2. The hardware serial port changes between the PP and the PPP, being ttyS2 in the original Pinephone, and ttyS3 in the Pro. It may happen, under rare circunstances, that a port gets stuck (it happened to biktorgj a few times) where the USB serial port couldn't be released by the kernel and you end up having ttyUSB2 moved, but it's not really normal._
