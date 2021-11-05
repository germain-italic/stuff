This script will list your backup points from `$RSDIR` (default: `/home/rsnapshot`) and let you type the name of the snapshot that will be deleted.

Then it will read your rotation intervals (name and quantity) from `/etc/rsnapshot.conf` and will perform deletion for each occurrence of the typed snapshot.

```
[root@server ~/stuff (main)]# ./rsnapshot-deleter.sh 

WHICH BACKUP POINT WOULD YOU LIKE TO DELETE?
(Please type only one)
mysnapshot  myothersnapshot	mythirdsnapshot  anothersnapshot
myothersnapshot

DELETING myothersnapshot

INTERVAL daily (25 copies):
    /home/rsnapshot/daily.0/myothersnapshot
    /home/rsnapshot/daily.1/myothersnapshot
    /home/rsnapshot/daily.2/myothersnapshot
    /home/rsnapshot/daily.3/myothersnapshot
    /home/rsnapshot/daily.4/myothersnapshot
    /home/rsnapshot/daily.5/myothersnapshot
    /home/rsnapshot/daily.6/myothersnapshot
    /home/rsnapshot/daily.7/myothersnapshot
    /home/rsnapshot/daily.8/myothersnapshot
    /home/rsnapshot/daily.9/myothersnapshot
    /home/rsnapshot/daily.10/myothersnapshot
    /home/rsnapshot/daily.11/myothersnapshot
    /home/rsnapshot/daily.12/myothersnapshot
    /home/rsnapshot/daily.13/myothersnapshot
    /home/rsnapshot/daily.14/myothersnapshot
    /home/rsnapshot/daily.15/myothersnapshot
    /home/rsnapshot/daily.16/myothersnapshot
    /home/rsnapshot/daily.17/myothersnapshot
    /home/rsnapshot/daily.18/myothersnapshot
    /home/rsnapshot/daily.19/myothersnapshot
    /home/rsnapshot/daily.20/myothersnapshot
    /home/rsnapshot/daily.21/myothersnapshot
    /home/rsnapshot/daily.22/myothersnapshot
    /home/rsnapshot/daily.23/myothersnapshot
    /home/rsnapshot/daily.24/myothersnapshot
    ERROR: THE BACKUP POINT /home/rsnapshot/daily.25/myothersnapshot DOES NOT EXIST.

INTERVAL monthly (1 copies):
    /home/rsnapshot/monthly.0/myothersnapshot
    ERROR: THE BACKUP POINT /home/rsnapshot/monthly.1/myothersnapshot DOES NOT EXIST.
```