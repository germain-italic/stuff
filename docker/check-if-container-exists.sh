#!/bin/bash

# cron example
# 0 2 * * * /root/check_gitlab_container.sh> /dev/null 2>&1

CONTAINER=gitlab
docker inspect --format="{{.State.Running}}" $CONTAINER
if [ $? -eq 0 ];
then
    echo "container gitlab exists"
else
    echo "missing container gitlab"
    MESSAGE="Il n'y a pas de container intitulé 'gitlab' sur xxx,\n"
    MESSAGE="${MESSAGE}le cron de backup ne peut donc pas s'exécuter !\n"
    MESSAGE="${MESSAGE}Lancez Portainer pour inspecter : http://xxx:xxx/#!/auth"
    echo -e "Subject:!!! ALERTE CONTAINER GITLAB MANQUANT !!!\n$MESSAGE" | /usr/sbin/sendmail xxx
fi