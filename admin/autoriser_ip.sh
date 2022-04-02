#!/bin/bash

# todo:
# - include colors from external list
# - ask for user input instead of --comment xxxx

black() {
        echo -e "\e[30m${1}\e[0m"
}

red() {
        echo -e "\e[31m${1}\e[0m"
}

green() {
        echo -e "\e[32m${1}\e[0m"
}

yellow() {
        echo -e "\e[33m${1}\e[0m"
}

blue() {
        echo -e "\e[34m${1}\e[0m"
}

magenta() {
        echo -e "\e[35m${1}\e[0m"
}

cyan() {
        echo -e "\e[36m${1}\e[0m"
}

gray() {
        echo -e "\e[90m${1}\e[0m"
}

#black 'BLACK'
#red 'RED'
#green 'GREEN'
#yellow 'YELLOW'
#blue 'BLUE'
#magenta 'MAGENTA'
#cyan 'CYAN'
#gray 'GRAY'
#echo $(green "GREEN MESSAGE")
#exit 1

printf "\n\n"
echo $(yellow "Script de whitelistage d'une adresse IP V4 sur ports 80 et 443")
echo $(yellow "==============================================================")
printf "\n\n"

echo "Quelle adresse IP souhaitez-vous whitelister ?"

read ip

echo "Vous avez saisi l'adresse : $(yellow  $ip)"

printf "\n\n"

echo "Commentaire à mettre dans la règle du firewall :"

read comment


if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo $(green "Adresse IP V4 valide")

        COMMAND="iptables -A INPUT -s ${ip}/32 -p tcp -m multiport --dports 80,443 -m comment --comment ${comment} -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT"

        echo "Voulez-vous executer cette commande ? (oui/non)"
        echo $(red "$COMMAND")
        read accept

        if [ $accept = "oui" ]
        then
                eval "$COMMAND"
                service netfilter-persistent save
                service netfilter-persistent reload

                echo $(green "Dernière ligne ajoutée au firewall :")
                iptables -S > autoriser_ip_output.txt
                tail -n  4 autoriser_ip_output.txt | head -n 1
                exit 1
        else
                echo "Aucune operation effectuee."
                exit 1
        fi


else
        echo $(green "Adresse IP V4 non valide")
fi


