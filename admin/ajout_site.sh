#!/bin/bash

# Forked from https://gist.githubusercontent.com/jonathanbossenger/2dc5d5a00e20d63bd84844af89b1bbb4/raw/23e38e40602a5c322008b2fd72fb59c49450db70/sitesetup.sh

# Bash script to set up local site using LAMP on Ubuntu
# Requires Apache2, MySQL, mkcert, dbdeployer, colorize
# See also sitedrop.sh https://gist.github.com/jonathanbossenger/4950e107b0004a8ee82aae8b123cce58


# colorize: get it from
# https://raw.githubusercontent.com/Germain-Italic/stuff/admin/colorize
# todo: check if file exists, if not, download it
PWD=$(dirname "$(readlink -f "$0")")
source "${PWD}/colorize"


# your local environment
# todo: read from .env file
# todo: check if mkcert is installed
HOME_USER=germain
SSL_CERTS_DIRECTORY=/home/germain/ssl-certs
SITES_DIRECTORY=/home/germain/Sites
MKCERT_EXECUTABLE=/usr/local/bin/mkcert
APACHE_SITES_PATH=/etc/apache2/sites-available
PHP_SOCKETS_PATH=/var/run/php/*.sock
SERVER_ADMIN=germain@localhost





########
# FQDN #
########

echo -e $(yellow "What is the site FQDN? (eg: my.site.localhost)")
read FQDN

SITE_NAME=${FQDN%.*}
#echo $SITE_NAME

TLD=${FQDN//*.}
#echo $TLD





##############
# <Directoy> #
##############

printf "\n"
echo -e $(yellow "Where is the site directory? (eg: /home/germain/sites/my.site)")
echo -e $(gray "Leave blank to create $SITES_DIRECTORY/$SITE_NAME")
read -e -p "" DIRECTORY


if [ -z "$DIRECTORY" ]
then
	DIRECTORY=${SITES_DIRECTORY}/${SITE_NAME}
fi


if [ -d "$DIRECTORY" ]
then
        echo $(green "Directory $DIRECTORY exists")
else
	echo $(blue "Creating websites directory $DIRECTORY")
	mkdir -p $DIRECTORY
	ls $SITES_DIRECTORY
fi





################
# DocumentRoot #
################

printf "\n"
echo -e $(yellow "Which subfolder is the DocumentRoot (eg: www, public_html, httpdocs, web)")
echo -e $(gray "Leave blank to use $DIRECTORY")
read -e -p "" DOC_ROOT


if [ -z "$DOC_ROOT" ]
then
        DOC_ROOT=${DIRECTOY}
fi


if [ -d "$DIRECTORY/$DOC_ROOT" ]
then
        echo $(green "Existing $DIRECTORY/$DOC_ROOT will be used as DocumentRoot")
	ls ${DIRECTORY}/${DOC_ROOT}
else
        echo $(green "Creating DocumentRoot folder $DIRECTORY/$DOC_ROOT")
        mkdir -p ${DIRECTORY}/${DOC_ROOT}
	ls ${DIRECTORY}
fi




###############
# ServerAdmin #
###############

printf "\n"
echo -e $(yellow "Who is the ServerAdmin?")
echo -e $(gray "Leave blank to use $SERVER_ADMIN")
read -e -p "" SERVER_ADMIN_INPUT


if [ -z "$SERVER_ADMIN_INPUT" ]
then
        SERVER_ADMIN=${SERVER_ADMIN_INPUT}
fi
echo $(green "Using $SERVER_ADMIN")





###########
# PHP-FPM #
###########

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








########
# HTTP #
########

SITE_CONFIG_PATH=$APACHE_SITES_PATH/$SITE_NAME.conf
SSL_SITE_CONFIG_PATH=$APACHE_SITES_PATH/$SITE_NAME-ssl.conf


echo "Setting up virtual hosts..."

VIRTUAL_HOST="<VirtualHost *:80>
    ServerName $FQDN
    Redirect / https://$FQDN
</VirtualHost>"

echo "$VIRTUAL_HOST" | sudo tee -a "$SITE_CONFIG_PATH"

SSL_VIRTUAL_HOST="<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerName $FQDN
        ServerAdmin $SERVER_ADMIN
        DocumentRoot $SITES_DIRECTORY/$DOC_ROOT
        <Directory \"$SITES_DIRECTORY\">
		Options -Indexes +FollowSymLinks +MultiViews
            	AllowOverride All
            	Require all granted
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/$SITE_NAME-error.log
        CustomLog \${APACHE_LOG_DIR}/$SITE_NAME-access.log combined
        SSLEngine on
        SSLCertificateFile  $SSL_CERTS_DIRECTORY/$FQDN.pem
        SSLCertificateKeyFile $SSL_CERTS_DIRECTORY/$FQDN-key.pem
        <FilesMatch \"\.(cgi|shtml|phtml|php)\$\">
                SSLOptions +StdEnvVars
		# todo: create a separate pool and socket for each website
		SetHandler "proxy:unix:/var/run/php/php7.4-fpm.sock|fcgi://localhost/"
        </FilesMatch>
    </VirtualHost>
</IfModule>"

echo "$SSL_VIRTUAL_HOST" | sudo tee -a "$SSL_SITE_CONFIG_PATH"

echo "Enabling virtual hosts..."

#a2ensite "$FQDN".conf
#a2ensite "$FQDN"-ssl.conf

echo "Add hosts record.."

#echo "127.0.0.1    $FQDN$SITE_TLD" >> /etc/hosts

echo "Creating database.."

MYSQL_DATABASE=$(echo $FQDN | sed 's/[^a-zA-Z0-9]//g')


#mysql -uroot -ppassword --execute="CREATE DATABASE $MYSQL_DATABASE;"

echo "Add certs.."

#runuser -l jonathan -c "cd $SSL_CERTS_DIRECTORY && $MKCERT_EXECUTABLE $FQDN$SITE_TLD"

echo "Restarting Apache..."

#service apache2 restart

echo "Done."
