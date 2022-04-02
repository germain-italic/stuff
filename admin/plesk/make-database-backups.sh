#!/bin/bash

LOCAL_DEST="/root/mysql_dumps_all"
REMOTE_DEST="/home/germain/Sites/mysql_dumps_all"

mkdir -p $LOCAL_DEST

/usr/sbin/plesk db -e "show databases" | \
    grep -v -E "^Database|information_schema|performance_schema|phpmyadmin" > "$LOCAL_DEST"/dblist.txt

cat "$LOCAL_DEST"/dblist.txt | while read i; \
    do /usr/sbin/plesk db dump "$i" > "$LOCAL_DEST"/"$i".sql; \
done;

scp -r $LOCAL_DEST germain@ip:"$REMOTE_DEST"