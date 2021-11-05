#!/bin/bash

RSDIR="/home/rsnapshot"
BKPOINTS="daily.0"



echo -e "\nWHICH BACKUP POINT WOULD YOU LIKE TO DELETE?"
echo -e "(Please type only one)"

for BKPOINT in "${RSDIR}/${BKPOINTS}/"
do
   ls $BKPOINT
done

read DELETE

echo -e "\nDELETING $DELETE"

INTERVALS=`/bin/grep -i "retain" /etc/rsnapshot.conf | /usr/bin/awk '{print $2}'`
for INTERVAL in ${INTERVALS}
do

   RETAINS=`/bin/grep -iP "retain\t${INTERVAL}" /etc/rsnapshot.conf | /usr/bin/awk '{print $3}'`
   echo -e "\nINTERVAL ${INTERVAL} (${RETAINS} copies):"

   for i in $(/usr/bin/seq 0 $RETAINS)
   do
      PATH="${RSDIR}/${INTERVAL}.${i}/${DELETE}"
      if [ -d $PATH ] 
      then
         # SIZE=`/usr/bin/find $PATH -exec /usr/bin/du -s {} + | /usr/bin/awk '{total = total + $1}END{print (total / 1024 / 1024) "MB"}'`
         # echo "    $PATH $SIZE" 
         echo "    $PATH" 
         /bin/rm -rf $PATH
      else
         echo "    ERROR: THE BACKUP POINT $PATH DOES NOT EXIST." 
         # exit 1
      fi
   done

done