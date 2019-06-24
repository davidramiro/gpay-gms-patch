#!/system/bin/sh

# check magiskhide status
check_magiskhide() {
  if ! /sbin/magiskhide status; then
    echo "MagiskHide not found or disabled."
    echo "Do you want to try enabling MagiskHide?"
    select ysa in "Yes" "Skip MagiskHide" "Abort"; do
      case $ysa in
      "Yes")
        echo ""
        echo "Enabling MagiskHide..."
        if /sbin/magiskhide enable; then
          echo "Successfully enabled. Moving on..."
          sleep 1
        else
          echo "Could not enable MagiskHide."
          sleep 1
          exit 1
        fi
        hide_packages
        break
        ;;
      "Skip MagiskHide")
        echo ""
        echo "Continuing without MagiskHide..."
        sleep 1
        break
        ;;
      "Abort")
        echo ""
        echo "Exiting..."
        sleep 1
        exit 0
        ;;
      esac
    done
  else
    hide_packages
  fi
  echo ""
  sleep 3
}

# enable magiskhide for relevant packages
hide_packages() {
  pkgs=(com.google.android.gms com.paypal.android.p2pmobile com.google.android.apps.walletnfcrel com.google.android.ext.services com.google.android.gsf)
  for i in "${pkgs[@]}"; do
    /sbin/magiskhide add $i
    echo "Hiding $i..."
  done
  echo ""
  sleep 3
}

check_sqlite() {
  if [ ! -f "/data/local/sqlite3" ]; then
    echo "SQLite3 not found. Do you want to download it now? "
    # prompt user if download is wanted
    select yn in "Yes" "No"; do
      case $yn in
      Yes)
        echo "Getting device architecture..."
        abi=$(getprop ro.product.cpu.abi)
        echo "Device architecture is $abi."
        echo ""
        sleep 1
        echo "Downloading SQLite3 binary for $abi..."
        # use device architecture in the download url
        if [ -x "$(command -v curl)" ]; then
          curl -o /data/local/sqlite3 https://raw.githubusercontent.com/davidramiro/gpay-gms-patch/master/bin/"$abi"/sqlite3
        else
          if [ -x "$(command -v wget)" ]; then
            wget -P /data/local/ https://raw.githubusercontent.com/davidramiro/gpay-gms-patch/master/bin/"$abi"/sqlite3
          else
            echo "Neither wget nor curl are available on your phone."
            echo "To fix this, do one of the following steps:"
            echo " - Download SQLite3 manually, place it into /data/local and chmod 755 it"
            echo " - Install Busybox by osm0sis via Magisk"
            echo " - Use Termux from Play Store (ships with wget)"
            echo " - Install a wget or curl binary manually"
            echo ""
            echo "Exiting..."
            exit 1
          fi
        fi
        sleep 2
        # check if download worked before continuing
        if [ -f "/data/local/sqlite3" ]; then
          echo "Applying permissions..."
          chmod 755 /data/local/sqlite3
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
      No)
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
    sleep 1
  fi
  echo ""
  sleep 3
}

# main
clear
echo " ** gpay-gms-patch **"
echo "    by davidramiro"
echo ""
echo ""

# check for root
if [ $(id -u) = 0 ]; then
  echo "We are root. Let's go!"
  echo ""
  sleep 1
else
  echo "Script needs to be run as root. Did you use 'su'?"
  exit 1
fi

# user menu
echo "Hiding the packages mentioned on the GitHub repo is recommended."
echo "This script can do this for you."
echo "If you have already done so, you can go on patching the GMS database."
echo ""
sleep 1
select psa in "Patch Database Only" "Set up MagiskHide and Patch" "Abort"; do
  case $psa in
  "Patch Database Only")
    echo "Moving on..."
    sleep 1
    check_sqlite
    break
    ;;
  "Set up MagiskHide and Patch")
    echo ""
    sleep 1
    check_magiskhide
    check_sqlite
    break
    ;;
  "Abort")
    echo "Exiting..."
    sleep 1
    exit 0
    ;;
  esac
done

# force close gpay
echo "Stopping Google Pay..."
am force-stop com.google.android.apps.walletnfcrel
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
