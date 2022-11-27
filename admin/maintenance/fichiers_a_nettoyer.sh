#!/bin/bash

HOSTNAME=myserver
DOMAIN=domain.com
LOOKUP=/var/www

echo "From: root@$HOSTNAME.$DOMAIN" > /root/fichiers_a_nettoyer.log
echo "To: support@$DOMAIN" >> /root/fichiers_a_nettoyer.log
echo "Subject: Alerte fichiers volumineux sur $HOSTNAME" >> /root/fichiers_a_nettoyer.log
echo "Mime-Version: 1.0" >> /root/fichiers_a_nettoyer.log
echo "Content-Type: text/html; charset=UTF-8" >> /root/fichiers_a_nettoyer.log
echo "" >> /root/fichiers_a_nettoyer.log

echo "<html>" >> /root/fichiers_a_nettoyer.log
echo "Bonjour,<br>" >> /root/fichiers_a_nettoyer.log
echo "Nous avons d&eacute;tect&eacute; <b>des fichiers de grande taille</b> sur le serveur de prod $HOSTNAME.<br>" >> /root/fichiers_a_nettoyer.log
echo "Puisqu'ils sont backup&eacute;s sur plusieurs serveurs, <b>leur co&ucirc;t est important</b>.<br><br>" >> /root/fichiers_a_nettoyer.log
echo "Veuillez <b>supprimer les fichiers qui n'ont plus lieu d'&ecirc;tre</b> (sql, zip, tar, ...)<br>" >> /root/fichiers_a_nettoyer.log
echo "<b>Quant aux logs,</b> il convient de les supprimer pour les anciens projets et de les vider pour les projets r&eacute;cents/en prod.<br><br>" >> /root/fichiers_a_nettoyer.log
echo "Pour les gros assets l&eacute;gitimes (ex : videos) d&eacute;ja en prod, pensez a les exclure du backup manager de Plesk.<br><br>" >> /root/fichiers_a_nettoyer.log
echo "Rappel : les uploads, assets, vendors ne doivent g&eacute;n&eacute;ralement pas &ecirc;tre commit&eacute;s dans les repos GIT.<br><br>" >> /root/fichiers_a_nettoyer.log
echo "Merci de votre implication !<br>" >> /root/fichiers_a_nettoyer.log
echo "Germain" >> /root/fichiers_a_nettoyer.log

echo "<pre>" >> /root/fichiers_a_nettoyer.log
find $LOOKUP -size +100M -type f \( \
       ! -iname "*.pack" \
       ! -iname "*.git" \
       ! -iname "*.mp4" \
       ! -iname "*.mov" \
     \) -exec du -h {} \; >> /root/fichiers_a_nettoyer.log
echo "</pre>" >> /root/fichiers_a_nettoyer.log

echo "</html>" >> /root/fichiers_a_nettoyer.log

file_size_bytes=`du -b /root/fichiers_a_nettoyer.log | cut -f1`

if [ $file_size_bytes -gt 789 ]
    then
       # pour sendmail
       #cat /root/fichiers_a_nettoyer.log | /usr/lib/sendmail -t
       # pour msmtp
       #cat /root/fichiers_a_nettoyer.log | /usr/local/bin/msmtp support@$DOMAIN
    else
        #echo "pas de fichier"
        exit 0
fi


# crontab:
# 0 3 * * * /root/fichiers_a_nettoyer.sh
