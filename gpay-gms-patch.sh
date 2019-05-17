#!/sbin/su

# mount /system with write permissions
echo "mounting /system with rw..."
mount -o remount,rw /system

# checking if sqlite3 is present
if [ -f "/system/xbin/sqlite3" ]
then
	echo "sqlite3 binary is present. moving on."
else
	echo "sqlite3 binary not found. downloading..."
	cd /system/xbin/
	curl -O https://raw.githubusercontent.com/davidramiro/gpay-gms-patch/master/bin/sqlite3
	chmod 755 sqlite3
fi

# force close gpay
echo "stopping google pay..."
am force-stop /data/data/com.google.android.apps.walletnfcrel

# if the file was already altered before, set its original permissions
echo "setting default permissions..."
chmod 660 /data/data/com.google.android.gms/databases/dg.db

# set 0 on every row containing "attest" on dg.db from GMS
echo "editing database..."
/system/xbin/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"

# make the file read-only
echo "setting file read only..."
chmod 440 /data/data/com.google.android.gms/databases/dg.db

echo "all done! reboot and enjoy google pay."
