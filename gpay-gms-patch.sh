#!/system/bin/sh

echo ""

# check for root
if [ $(id -u) = 0 ]
then
  echo "We are root. Let's go!"
else
  echo "Script needs to be run as root. Did you use 'su'?"
  exit 1
fi

# checking if sqlite3 is missing
if [ ! -f "/data/local/sqlite3" ]
then
  echo "SQLite3 not found. Do you want to download it now? "
  # prompt user if download is wanted
  select yn in "Yes" "No"; do
    case $yn in
      Yes )
        echo "Getting device architecture..."
        abi=$(getprop ro.product.cpu.abi)
        echo "Device architecture is $abi."
        echo ""
        sleep 1
        echo "Downloading SQLite3 binary for $abi..."
        cd /data/local/
        # use device architecture in the download url
        curl -O https://raw.githubusercontent.com/davidramiro/gpay-gms-patch/master/bin/"$abi"/sqlite3
        sleep 2
        # check if download worked before continuing
        if [ -f "/data/local/sqlite3" ]
        then
          echo "Applying permissions..."
          chmod 755 sqlite3
          sleep 1
          echo "SQLite3 installed in /data/local."
          echo ""
          sleep 1
        else
          echo "Download failed. Internet/permission issue?"
          echo "Exiting..."
          sleep 1
          exit 1
        fi
        break
        ;;
      No )
        echo ""
        echo "This script needs an SQLite3 binary to be present in /data/local."
        echo "Please download it manually and use chmod 755."
        echo "Exiting..."
        sleep 1
        exit 1
        ;;
    esac
  done
else
  echo "SQLite3 binary is present. Moving on."
  echo ""
  sleep 2
fi

# force close gpay
echo "Stopping Google Pay..."
am force-stop /data/data/com.google.android.apps.walletnfcrel
echo ""
sleep 2

# if the file was already altered before, set its original permissions
echo "Setting default permissions on database..."
chmod 660 /data/data/com.google.android.gms/databases/dg.db
echo ""
sleep 2

# set 0 on every row containing "attest" on dg.db from GMS
echo "Editing database..."
/data/local/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"
echo ""
sleep 2

# make the file read-only
echo "Setting database as read-only..."
chmod 440 /data/data/com.google.android.gms/databases/dg.db
echo ""
sleep 2


echo "All done! Reboot, add your cards to Google Pay and have fun."
echo "Big thanks to BostonDan@XDA!"
echo ""
exit 0
