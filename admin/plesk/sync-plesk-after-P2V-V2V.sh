#!/bin/bash
#
# Written by https://github.com/germain-italic
# Related blog post https://www.germain.lol/conversion-dun-serveur-plesk-physique-vers-une-vm-esxi/
#
#
# This script is must be run on the # DESTINATION # server.
# ---------------------------------------------------------
#
# It will NOT perform a Plesk migration.
#
# It will NOT change Plesk configuration and users.
#
# It will ONLY sync files and databases of EXISTING websites
# on both source and destination.
# The destination must be an existing copy of the source.
#
# Example scenario:
# - Have a physical or virtual server running Plesk 18.x (Obsidian)
# - Create a P2V or V2V copy of the server to a new VM
#   => The copy takes HOURS, therefore you can't shutdown the source server
#   => After P2V/V2V you have to reconfigure network, MariaDB, Postfix, pfSense, license
#   => And you must test all the websites to ensure they work properly
#   => You have to create a maintenance homepage on a different VM that works for all sites (with SSL)
# - When the virtual destination is ready, you switch the production IP to the maintenance VM
# - Use ../check-503.sh to ensure that your websites return the 503 status
# - Then run this script to sync home directories and databases to the new VM
# - Test all the websites to ensure they still work properly, and are up-to-date
# - Finally, release the production IP the new Plesk VM


############################
# HOSTNAMES OR IP ADRESSES #
############################

source_server=''
maintenance_server='192.168.1.111'


# https://unix.stackexchange.com/questions/449498/call-function-declared-below
main() {
    if [ "$1" = yes ]; then
        
        ################################################
        # UNCOMMENT THE STEPS THAT YOU WANT TO PERFORM #
        ################################################
        
        #import_homedirs_to_destination
	#check_backwards_homedirs
        #import_source_certificates_on_destination
        #dump_source_databases
        #import_source_databases_on_destination
        #export_plesk_vhosts_to_apache_maintenance_vhosts
    else
        echo "doing nothing"
    fi
}


import_homedirs_to_destination() {

    mkdir "$now"


    ssh -p ${port} root@${source} '/usr/sbin/plesk db -e "USE psa; SELECT home FROM sys_users;" > /root/homedirs.txt'
    scp -P ${port} root@${source}:/root/homedirs.txt /root/homedirs.txt
    sed -i '1d' /root/homedirs.txt

    n=1
    while read line; do
        echo -e "\nLine No. $n : $line" >> "${now}/${source}.txt"
        n=$((n+1))
        rsync -avzun -e "ssh -p ${port}" "root@${source}:${line}/" "$line" >> "${now}/${source}.txt"
    done < /root/homedirs.txt
}




check_backwards_homedirs() {
    mkdir "$now"

    #ssh -p ${port} root@${source} '/usr/sbin/plesk db -e "USE psa; SELECT home FROM sys_users;" > /root/homedirs.txt'
    #scp -P ${port} root@${source}:/root/homedirs.txt /root/homedirs.txt
    #sed -i '1d' /root/homedirs.txt

    n=1
    while read line; do
        echo -e "\nLine No. $n : $line" >> "${now}/${source}.txt"
        n=$((n+1))
        rsync -rvn --size-only "$line" -e "ssh -p ${port}" "root@${source}:${line}/" >> "${now}/${source}.txt"
    done < /root/homedirs.txt
}




import_source_certificates_on_destination() {
    # https://support.plesk.com/hc/en-us/articles/115005147093-Where-do-Let-s-Encrypt-and-SSL-It-extensions-keep-pem-files-for-private-and-public-keys-on-a-file-system-
    rsync -avzu root@${source}:/usr/local/psa/var/modules/letsencrypt/ /usr/local/psa/var/modules/letsencrypt
    rsync -avzu root@${source}:/opt/psa/var/certificates/ /opt/psa/var/certificates

    ssh root@${maintenance} 'mkdir -p /etc/letsencrypt/live'
    rsync -avzu /opt/psa/var/certificates/ root@${maintenance}:/etc/letsencrypt/live
}



dump_source_databases()
    ssh root@${source} '\
        mkdir -p /root/mysql_dumps_all && \
        cd /root && \
        /usr/sbin/plesk db -e "show databases" | \
            grep -v -E "^Database|information_schema|performance_schema|phpmyadmin" \
        > dblist.txt && \
        cat /root/dblist.txt | while read i; \
            echo $i \
            do /usr/sbin/plesk db dump "$i" > /root/mysql_dumps_all/"$i".sql; \
        done;'
}



import_source_databases_on_destination() {
    mkdir -p /root/mysql_dumps_all
    rsync -avzu root@${source}:/root/mysql_dumps_all/ /root/mysql_dumps_all

    for i in `cat /root/dblist.txt`
    do
        MYSQL_PWD=`cat /etc/psa/.psa.shadow`
        mysql -u admin -p${MYSQL_PWD} < /root/mysql_dumps_all/"$i".sql;
    done
}



export_plesk_vhosts_to_apache_maintenance_vhosts() {

    MYSQL_PWD=`cat /etc/psa/.psa.shadow`
    DEST="/root/vhosts_maintenance"
    mkdir -p $DEST
    rm -rf "${DEST}/*.conf"

    ssh root@${maintenance} 'cd /etc/apache2/sites-available && \
                             a2dissite *.conf && \
                             rm *.conf && \
                             cp 000-default.{bak,conf} && \
                             cp 000-default-le-ssl.{bak,conf} && \
                             systemctl restart apache2'

    # domains
    QUERY="USE psa; \
           SELECT domains.id, domains.name \
           FROM domains \
           ORDER BY name ASC;"

    REQ_DOM=`mysql -u admin -p${MYSQL_PWD} -N -B -e "$QUERY"`
    j=0
    while IFS=$'\t' read dom_id domain cert_file ca_file ;do
        echo "$domain (id=$dom_id) ($j)"
        SERVERNAME="ServerName $domain"
        ((j++))


        # aliases
	    QUERY="USE psa; \
               SELECT name
               FROM domain_aliases
               WHERE dom_id = $dom_id;"

        REQ_ALIAS=`mysql -u admin -p${MYSQL_PWD} -N -B -e "$QUERY"`
        l=0
        TMP=''
        SERVERALIAS=''
        while IFS2=$'\t' read name ;do
            [ ! -z "$name" ] && echo "    $name ($l)"
            [ ! -z "$name" ] && TMP="$TMP $name"
            ((l++))
        done  < <(echo -e "$REQ_ALIAS")
        [  ! -z "$name" ] && SERVERALIAS="ServerAlias $TMP"




        # certificates
        QUERY="USE psa; \
               SELECT certificates.cert_file, certificates.ca_file
               FROM hosting
               INNER JOIN certificates ON (certificates.id = hosting.certificate_id)
               INNER JOIN domains ON (domains.id = hosting.dom_id)
               WHERE hosting.dom_id = $dom_id;"

        REQ_SSL=`mysql -u admin -p${MYSQL_PWD} -N -B -e "$QUERY"`
        m=0
        SSL_CERT=''
        SSL_CA=''
        while IFS3=$'\t' read cert_file ca_file ;do
            [  ! -z "$cert_file" ] && echo "        $cert_file $ca_file ($m)"
            [  ! -z "$cert_file" ] && SSL_CERT=$cert_file
            [  ! -z "$ca_file" ] && SSL_CA=$ca_file
            ((m++))
        done  < <(echo -e "$REQ_SSL")



        # vhost config file
        CONF="${DEST}/${domain}.conf"

        # http
        echo "<VirtualHost *:80>" > $CONF
	echo "    ServerName $domain" >> $CONF
        echo "    ServerAlias www.${domain}" >> $CONF
        if [ ! -z "$SERVERALIAS" ]
        then
	    echo "    $SERVERALIAS" >> $CONF
        fi
	echo "    DocumentRoot /var/www/html" >> $CONF
        echo "</VirtualHost>" >> $CONF


        # https
        if [ ! -z "$SSL_CERT" ]
        then
            echo "<VirtualHost *:443>" >> $CONF
            echo "    ServerName $domain" >> $CONF
            echo "    ServerAlias www.${domain}" >> $CONF
            if [ ! -z "$SERVERALIAS" ]
            then
                echo "    $SERVERALIAS" >> $CONF
            fi
            echo "    DocumentRoot /var/www/html" >> $CONF
            echo "    Include /etc/letsencrypt/options-ssl-apache.conf" >> $CONF
            echo "    SSLCertificateFile /etc/letsencrypt/live/${SSL_CERT}" >> $CONF
            echo "    SSLCACertificateFile /etc/letsencrypt/live/${SSL_CA}" >> $CONF
            echo "</VirtualHost>" >> $CONF
        fi


        #ssh root@${maintenance} 'rm /etc/apache/sites-available/"${domain}".conf'
        scp $CONF root@${maintenance}:/etc/apache2/sites-available/


    done  < <(echo -e "$REQ_DOM")

    ssh root@${maintenance} 'cd /etc/apache2/sites-available && a2ensite *.conf && systemctl reload apache2'


}


# https://unix.stackexchange.com/questions/449498/call-function-declared-below
main "$@"; exit
