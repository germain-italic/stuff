DURATION_DAYS=1

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

CHECK_BKP="find /storage1/gitlab/var/opt/backups/ -ctime -$DURATION_DAYS"

if [[ $($CHECK_BKP) ]]; then
    echo "There are files: $CHECK_BKP"
else
    echo "No files found"
    MESSAGE="Il n'y a pas eu de backup GitLab depuis $DURATION_DAYS jour !\n"
    MESSAGE="${MESSAGE}Vérifiez que le container s'appelle bien 'gitlab', qu'il tourne, qu'il y a de l'espace sur le disque.\n"
    MESSAGE="${MESSAGE}Lancez Portainer pour inspecter : http://xxx:xxx/#!/auth"
    echo -e "Subject:!!! ALERTE BACKUP GITLAB MANQUANT !!!\n$MESSAGE" | /usr/sbin/sendmail xxxx
fi
