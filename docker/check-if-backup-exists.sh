
#!/bin/bash

# cron example

# 0 1 * * * docker exec -t gitlab gitlab-ctl backup-etc CRON=1> /dev/null 2>&1

# 0 2 * * * /root/check_gitlab_container.sh> /dev/null 2>&1
# 0 3 * * * docker exec -t gitlab gitlab-rake gitlab:backup:create CRON=1
# 0 4 * * * /root/check_gitlab_backup.sh> /dev/null 2>&1

# 0 14 * * * /root/check_gitlab_container.sh> /dev/null 2>&1
# 0 15 * * * docker exec -t gitlab gitlab-rake gitlab:backup:create CRON=1
# 0 16 * * * /root/check_gitlab_backup.sh> /dev/null 2>&1


DURATION=90

#Other Settings
#-amin when the file was accessed in minutes
#-atime when the file was accessed in days
#-cmin when the file was created in minutes
#-ctime when the file was created in days
#-mmin when the file was modified in minutes
#-mtime when the file was modified in days
#
#Numerical parameters:
#-1 the last 24 hours
#-0.5 the last 12 hours
#-0.25 the last 6 hours
#+3 more than three days

CHECK_BKP="find /storage1/gitlab/var/opt/backups/ -cmin -$DURATION"

if [[ $($CHECK_BKP) ]]; then
    echo "There are files: $CHECK_BKP"
else
    echo "No files found"
    MESSAGE="Le backup GitLab n'a pas été effectué comme prévu il y a  $DURATION minutes !\n"
    MESSAGE="${MESSAGE}Vérifiez que le container s'appelle bien 'gitlab', qu'il tourne, qu'il y a de l'espace sur le disque.\n"
    MESSAGE="${MESSAGE}Lancez Portainer pour inspecter : http://xxx:xxx/#!/auth"
    echo -e "Subject:!!! ALERTE BACKUP GITLAB MANQUANT !!!\n$MESSAGE" | /usr/sbin/sendmail xxxx
fi
