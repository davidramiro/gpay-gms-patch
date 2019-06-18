# gpay-gms-patch
Google Pay can be pretty hard to get to work with Magisk, with this simple shell script you can get it to work flawlessly on the more recent versions of GPay, Google Play Services and Magisk.

I have included SQLite3 binaries from the official Android NDK, the script can automatically download the correct version from this repo, but feel free to use your own and place it into `/data/local` with its permissions set to 755.

For best results, I'd recommend hiding SU from the following packages via MagiskHide:
```
com.google.android.ext.services
com.google.android.apps.walletnfcrel
com.google.android.gms
com.google.android.gsf
com.paypal.android.p2pmobile
```
This can be done automatically with the script as well.

## Status
- Working as of 19.06.2019:
  - Android 9, June Security Patch
  - Magisk 19.3
  - Google Play Services <=17.4.55
  - Tested on Xiaomi Mi9 and Pixel 3 XL

## Prerequisites
- Magisk 19+
- A terminal emulator

## Usage
* Obfuscate Magisk Manager package string in Magisk settings
* Check if SafetyNet passes. If ctsProfile fails:
  * Spoof a legitimate device fingerprint (easy to do with [MagiskHide Props Config module](https://github.com/Magisk-Modules-Repo/MagiskHidePropsConf/blob/master/README.md#spoofing-devices-fingerprint-to-pass-the-ctsprofile-check))
* Transfer `gpay-gms-patch.sh` to your device
* Open your terminal emulator (or `adb shell`) and browse to the script's directory
* Make the script executable with `chmod +x gpay-gms-patch.sh`
* Get SU permissions by entering `su` (confirm the Magisk prompt)
* Execute the script by entering `sh gpay-gms-patch.sh`
* Follow the on screen instructions.
* Reboot the device and add your cards to Google Pay.

## What exactly does this do?
The method of this script is actually very simple, to spoof a legitimate Attestation state we just need to edit a few lines on a database included in the Google Play Service storage and lock it down afterwards, so the state cannot easily be changed again by Play Services. To read more about this topic, check the Android Developers documentation about SafetyNet Attestation API.  
Nothing fancy, I just wanted to automate the process of installing SQLite, setting up MagiskHide and editing the database. Hope it can be of use for somebody.

## Note on Updating
Of course this might get patched in the future. You can always roll back Google Play Services and redo the process. I will try to keep this repo updated if anything changes.
It might be a good idea to temporarily allow write access to the database file after Google Play Services gets updated. To do so, you would need to issue `chmod 660 /data/data/com.google.android.gms/databases/dg.db`. For now, it has worked without this step though.

## Credits
A big thank you to BostonDan from XDA for figuring out that the attestation state is stored in this particular file!
