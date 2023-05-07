#!/bin/bash
SRC_FS=rpool/USERDATA/berto_zbq731
DST_FS=backup/home_berto

# Calc last snapshot
OLD_SNAPSHOT=$(zfs list $SRC_FS -t snapshot -H|awk '{print $1}'|sort -r|head -1|awk -F '@' '{print $2}')
NEW_SNAPSHOT="snapshot_"$(date +%Y%m%d_%H%M%S)
sudo zfs snapshot $SRC_FS@$NEW_SNAPSHOT
if [ "$OLD_SNAPSHOT" == "" ]; then
  # No snapshot. I need to create the first one and do a full send/receive backup
  sudo zfs send $SRC_FS@$NEW_SNAPSHOT | sudo zfs receive $DST_FS
else
  # At least 1 snapshot exists. I need to do an incremental backup
  sudo zfs send -i $SRC_FS@$OLD_SNAPSHOT $SRC_FS@$NEW_SNAPSHOT | sudo zfs receive $DST_FS -F
fi
