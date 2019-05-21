# gpay-gms-patch
Google Pay can be pretty hard to get to work with Magisk, with this simple shell script you can get it to work flawlessly on the more recent versions of GPay, Google Play Services and Magisk.

I have included SQLite3 binaries from the official Android NDK, the script can automatically download the correct version from this repo, but feel free to use your own and place it into `/system/xbin` with its permissions set to 755.

## Tested on:
- Working as of 21.05.2019:
  - Xiaomi Mi9
  - Android 9, May Security Patch
  - Magisk 19.1
  - Google Play Services <=17.1.91

## Prerequisites
- Magisk 19+
- A terminal emulator

## Usage
* Use Magisk Hide to hide SU from:
```
com.google.android.ext.services
com.google.android.apps.walletnfcrel
com.google.android.gms
com.google.android.gsf
```
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

## Note on Updating
Of course this might get patched in the future. You can always roll back Google Play Services and redo the process. I will try to keep this repo updated if anything changes.
It might be a good idea to temporarily allow write access to the database file after Google Play Services gets updated. To do so, you would need to issue `chmod 660 /data/data/com.google.android.gms/databases/dg.db`. For now, it has worked without this step though.

## Credits
A big thank you to BostonDan from XDA for figuring out that the attestation state is stored in this particular file!
