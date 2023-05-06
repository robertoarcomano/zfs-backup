#!/bin/bash
FS=rpool/USERDATA/berto_zbq731/test
MOUNTPOINT=/home/berto/test
BACKUP_DIR=/home/berto/Documents/Papa
BACKUP_DIR1=/home/berto/Documents/moto
SNAPSHOT_NAME=snapshot_test
SNAPSHOT=$FS@$SNAPSHOT_NAME
SNAPSHOT1=$FS@$SNAPSHOT_NAME"1"

BACKUP_FS=backup/test
BACKUP_MOUNTPOINT=/mnt/backup/test
BACKUP_SNAPSHOT=$BACKUP_FS@$SNAPSHOT_NAME

# 1 Remove old snapshot and fs
#sudo zfs destroy $SNAPSHOT
sudo zfs destroy $FS -r

# 2 Create the local fs test
sudo zfs create $FS

# 3 Set the mountpoint to $MOUNTPOINT
sudo zfs set mountpoint=$MOUNTPOINT $FS

# 4 Copy some files
sudo rsync -a $BACKUP_DIR $MOUNTPOINT

# 5. Create snapshot
sudo zfs snapshot $SNAPSHOT

# 6. Remove old backup snapshot and fs
#sudo zfs destroy $BACKUP_SNAPSHOT
sudo zfs destroy $BACKUP_FS -r

# 7 Create the local fs test
#sudo zfs create $BACKUP_FS

# 8 Set the mountpoint to $BACKUP_MOUNTPOINT
#sudo zfs set mountpoint=$BACKUP_MOUNTPOINT $BACKUP_FS

# 9 Copy data to the backup using the send command
echo "Full copy"
date
sudo zfs send $SNAPSHOT | sudo zfs receive $BACKUP_FS
date
echo

# 10 Copy new data
sudo rsync -a $BACKUP_DIR1 $MOUNTPOINT

# 11 Create new snapshot
sudo zfs snapshot $SNAPSHOT1

# 12 Sync data to backup
echo "Incremental copy"
date
sudo zfs send -i $SNAPSHOT $SNAPSHOT1 | sudo zfs receive $BACKUP_FS
date



