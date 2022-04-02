#!/bin/bash
filename='all_domains.txt'

n=1
while read line; do
    #echo "Line No. $n : $line"

    IFS=' '     # space is set as delimiter
    read -ra ADDR <<< "$line"   # str is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do   # access each element of array
        RESPONSE=`/usr/bin/curl -ILs --connect-timeout 5 --max-time 5 $i | head -1`

        if [[ $RESPONSE != *"HTTP/1.1 503 Service Unavailable"* ]]; then
            echo "$i"
            echo "$RESPONSE"
        fi

    done

    # while IFS=$' ' read domain ;do
    #     echo "$domain "
    # done  < <(echo -e "$line")

    n=$((n+1))
done < $filename