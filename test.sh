#!/bin/bash

PHP_SOCKETS_PATH=/var/run/php/*.sock



PWD=$(dirname "$(readlink -f "$0")")
source "${PWD}/colorize"


printf "\n"
echo -e $(yellow "Which PHP-FPM version would you like to use?")
echo -e $(gray "Leave blank to disable PHP")

PHP_SOCKETS=($(ls -d $PHP_SOCKETS_PATH))
select SOCKET in "${PHP_SOCKETS[@]}"; do
  case "$SOCKET" in
    "") break ;; 
    *) SOCKET=$REPLY break ;;
  esac
done

echo "reply : $REPLY ${PHP_SOCKETS[$REPLY]}"
((REPLY--))
echo "reply : $REPLY ${PHP_SOCKETS[$REPLY]}"

PHP_SOCKET=${PHP_SOCKETS[$REPLY]}
echo "ok : $PHP_SOCKET"
