#!/bin/bash

rm /root/fichiers_a_nettoyer.log
touch /root/fichiers_a_nettoyer.log

echo "Bonjour," >> /root/fichiers_a_nettoyer.log
echo "Nous avons d&eacute;tect&eacute; <b>des fichiers de grande taille</b> sur le serveur de preprod." >> /root/fichiers_a_nettoyer.log
echo "Puisqu'ils sont backup&eacute;s sur plusieurs serveurs, <b>leur co&ucirc;t est important</b>.<br>" >> /root/fichiers_a_nettoyer.log
echo "Veuillez <b>supprimer les fichiers qui n'ont plus lieu d'&ecirc;tre</b> (sql, zip, tar, ...)" >> /root/fichiers_a_nettoyer.log
echo "<b>Quant aux logs,</b> il convient de les supprimer pour les anciens projets et de les vider pour les projets r&eacute;cents/en prod.<br>" >> /root/fichiers_a_nettoyer.log
echo "Pour les gros assets l&eacute;gitimes (ex : videos) d&eacute;ja en prod, gardez-en une copie sur Google Drive puis supprimez-les de la preprod.<br>" >> /root/fichiers_a_nettoyer.log
echo "Rappel : les uploads, assets, vendors ne doivent g&eacute;n&eacute;ralement pas &ecirc;tre commit&eacute;s dans les repos GIT.<br>" >> /root/fichiers_a_nettoyer.log
echo "Merci de votre implication !" >> /root/fichiers_a_nettoyer.log
echo "Germain" >> /root/fichiers_a_nettoyer.log

echo "<pre>" >> /root/fichiers_a_nettoyer.log
find /var/chroot -size +150M -type f \( ! -iname "*.pack" ! -iname "*.git" \) -exec du -h {} \; >> /root/fichiers_a_nettoyer.log
echo "</pre>" >> /root/fichiers_a_nettoyer.log

cat fichiers_a_nettoyer.log | mail -s "Alerte fichiers volumineux sur NotLive" xxx@xxx.xxx
