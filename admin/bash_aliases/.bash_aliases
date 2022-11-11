#!/bin/bash

# If not running interactively, don't do anything
# (this should be in ~/.bashrc already)
case $- in
    *i*) ;;
      *) return;;
esac

# Change the version of this file after editing it
export VERSION_ALIASES=20

# My prefered editor
export EDITOR="nano"
export VISUAL="nano"


################
# Font styling #
################

# Text colors ("t" prefixed)
tblack=`tput setaf 0`
tred=`tput setaf 1`
tgreen=`tput setaf 2`
tyellow=`tput setaf 3`
tblue=`tput setaf 4`
tmagenta=`tput setaf 5`
tcyan=`tput setaf 6`
twhite=`tput setaf 7`

# Background colors ("bg" prefixed)
bgblack=`tput setab 0`
bgred=`tput setab 1`
bggreen=`tput setab 2`
bgyellow=`tput setab 3`
bgblue=`tput setab 4`
bgmagenta=`tput setab 5`
bgcyan=`tput setab 6`
bgwhite=`tput setab 7`

# Styles
titalic=`tput sitm`
tbold=`tput bold`
tdim=`tput dim`
tul=`tput smul`
ttitle=`tput smso && tput bold`
thighlight=`tput smso`

# Reset styles
_tul=`tput rmul`
_ttitle=`tput rmso && tput sgr0`
_thighlight=`tput rmso`
declare {treset,reset,tnormal,normal,_titalic,_tbold,_tdim}=`tput sgr0`
declare {_bgblack,_bgred,_bggreen,_bgyellow,_bgblue,_bgmagenta,_bgcyan,_bgwhite}=$reset
declare {_tblack,_tred,_tgreen,_tyellow,_tblue,_tmagenta,_tcyan,_twhite}=$treset

styles_shortcuts () {
    echo "Normal text = ${tdim}echo \" ... \"${_tdim}"
    echo "${ttitle}Title${_ttitle}       = ${tdim}\${ttitle} ... \${_ttitle} ${_tdim}"
    echo "${thighlight}Highlight${_thighlight}   = ${tdim}\${thighlight} ... \${_thighlight} ${_tdim}"
    echo "${tdim}Dimmed${_tdim}      = ${tdim}\${tdim} ... \${_tdim} ${_tdim}"
    echo "${tbold}Bold${_tbold}        = ${tdim}\${tbold} ... \${_tbold} ${_tdim}"
    echo "${titalic}Italic${_titalic}      = ${tdim}\${titalic} ... \${_titalic} ${_tdim}"
    echo "${tul}Underlined${_tul}  = ${tdim}\${tul} ... \${_tul} ${_tdim}"

    colors_list=(black red green yellow blue magenta cyan white)
    n=${1:-20}
    for var in "${colors_list[@]}"; do
        color="t${var}"
        cmd="\${${color}} ... \${_${color}}"

        bgcolor="bg${var}"
        bgcmd="\${${bgcolor}} ... \${_${bgcolor}}"

        echo -n "${!bgcolor}X${normal} "

        col1="${!color}${var}${normal}"$(printf '%*s' "$n" "") # pad with `n` spaces.
        col2=$(echo "${col1}"|grep -Eo "^.{1,$n}") # limit length to `n`
        printf "%s = ${tdim}$bgcmd   $cmd${_tdim}\n" "${col2}"

    done
}


#############################
# group: aliases management #
#############################

aliases_help () {
    echo "This is ~/.bash_aliases file version: ${tmagenta}$VERSION_ALIASES${_tmagenta}."
    echo "Type ${thighlight}aliases${_thighlight} to re-sync from GitHub, ${thighlight}ale${_thighlight} to edit, ${thighlight}als${_thighlight} to source, ${thighlight}all${_thighlight} for help."
    echo ""
    echo "List of available aliases:"
    echo "--------------------------"
    i=1
    prefix_alias='alias '
    prefix_help='# '
    prefix_groups='# group: '
    suffix_groups=' #'
    while read row; do
        line=$(sed "${i}q;d" ~/.bash_aliases)

        if [[ $line == $prefix_groups* ]]
        then
        group=${row#$prefix_groups}
        group=${group%$suffix_groups}
            echo -e "\n${ttitle}$group${_ttitle}"
        fi

        if [[ $line == $prefix_alias* ]]
        then
            # extract alias
            cmd="${line%%=*}"
            cmd="${cmd##alias}"

            # check if line above alias is a help line
            j=$(($i-1))
            above=$(sed "${j}q;d" ~/.bash_aliases)
            if [[ $above == $prefix_help* ]]
            then
                echo $cmd ${tdim}${above#$prefix_help}${_tdim}
            else
                echo $cmd
            fi
        fi
        let i=i+1
    done <~/.bash_aliases

    echo ""
    echo "List of available styles:"
    echo "-------------------------"
    styles_shortcuts
}

# edit aliases locally
alias ale='$EDITOR ~/.bash_aliases'
# source local alias file
alias als='source ~/.bash_aliases && echo "Aliases re-sourced. Type ${thighlight}all${_thighlight} for help."'
# show all aliases and local file version
alias all=aliases_help
alias al=all
# download aliases from GitHub, source the local file, show all aliases and local file version
alias aliases='wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/bash_aliases/.bash_aliases && als && al'


################
# group: lists #
################

# quick list (alphabetical)
alias l='ls -Fh --color=auto --group-directories-first'
# quick list (sorted by date)
alias ld='ls -Frth --color=auto --group-directories-first'
# quick list (sorted by size)
alias lz='ls --human-readable --size -1 -S --classify --color=auto'
filesize_by_extension () {
    find . -name '*' -type f -printf '%b.%f\0' | awk -F . -v RS='\0' '{if (NF==2) $(NF+1)=" "; s[$NF] += $1; n[$NF]++} END {for (e in s) printf "%15d %6d  %s\n", s[e]*512, n[e], e}' | sort -rn | numfmt --to=iec-i --suffix=B
}
# filesize by extensions
alias fz=filesize_by_extension
# detailed list (alphabetical) [optional filename]
alias ll='ls -lahF --color=auto --group-directories-first'
# detailed list (sorted by date) [optional filename]
alias lld='ls -trlahF --color=auto --group-directories-first'
# # detailed list (alphabetical) with numeric chmod
# alias ll="ls -lhaF --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
# # detailed list (sorted by date) with numeric chmod
# alias lld="ls -trlhaF --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"


#####################
# group: navigation #
#####################

# go 1 level up
alias ..='cd ..'
# go 2 levels up
alias ...='cd ../../'
# go 3 levels up
alias ....='cd ../../../'
# go 4 levels up
alias .....='cd ../../../'
# go 5 levels up
alias ......='cd ../../../../'
# go 6 levels up
alias .......='cd ../../../../../'
# go to specified directory (cd) and list it
alias cc=GoAndList
# go back to previous folder
alias back='cd -'
# go to /
alias root="cd /"
# go to Linux home directory (~) and list it
alias home="cd ~ && echo -n 'Current directory is now ' && pwd && l"
# go to WLS-mounted Windows home directory (/mnt/c/Users/$USER) and list it
alias homewin="cd /mnt/c/Users/$USER && echo -n 'Current directory is now ' && pwd && l"

function GoAndList() {
    DIR="$*";
    # # if no DIR given, go home
    # if [ $# -lt 1 ]; then
    #     DIR=$HOME;
    # fi;
    builtin cd "${DIR}" && echo -n 'Current directory is now ' && pwd && l
}


####################
# group: shortcuts #
####################

# search in history
alias h='history|grep'
# create compressed tar archive
alias untar='tar -zxvf $1'
# extract compressed tar archive
alias tar='tar -czvf $1'
# count files in current directory
alias count='find . -type f | wc -l'
# show Linux distribution version
alias release='cat /etc/*release'
# copy with progress bar
alias cpp='rsync -ah --info=progress2'


#####################################
# group: safery and common mistakes #
#####################################

alias chwon='chown'
# add --preserve-root
alias chown='chown --preserve-root'
# add --preserve-root
alias chmod='chmod --preserve-root'
# add --preserve-root
alias chgrp='chgrp --preserve-root'
# add -p
alias mkdir='mkdir -p'
# colorize (e)grep output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
# 3 pings are enough
alias ping='ping -c 3'
# ask confirmation and add --preserve-root
alias rm='rm -I --preserve-root'
# ask confirmation
alias mv='mv -i'
# ask confirmation
alias ln='ln -i'
# ask confirmation
alias rm='rm -i'
# ask confirmation, set recursive, preserve mode ownership timestamps
alias cp='cp -rp'
# make sudo work when evoking aliases
alias sudo='sudo '
# check globstar status
alias glob='shopt globstar'
# enable globstar (recursive expansion with **)
alias globon='shopt -s globstar'


####################
# group: utilities #
####################

# duplicate a file/folder or create a .bak copy, usage:
# bak [source]
# bak ~/folder/subfolder/file.txt
# dup [source] [destination]
# dup ~/folder/subfolder/file.txt file.sh
backup_file () {
    _1=$(echo $1 | sed 's:/*$::')
    _filename=$(echo $_1 | sed 's|.*/||')
    [[ -z $_1 ]] && echo "Missing source filename" && return
    [[ ! -f $_1 ]] && [[ ! -d $_1 ]] && echo "$_1 not found" && return

    _path=$(dirname -- "$_1")
    _target="${_path%/}/$_filename.bak"

    [[ -d $_target ]] || [[ -f $_target ]] && echo "$_target already exists" && return

    cp -rp "$_1" "$_target"
    cd $_path
    l
}
# create a .bak copy without retyping path, usage: bak [source]
alias bak='backup_file $1'

duplicate_file () {
    _1=$(echo $1 | sed 's:/*$::')
    _2=$(echo $2 | sed 's:/*$::')

    [[ -z $_1 ]] && echo "Missing source filename" && return
    [[ ! -f $_1 ]] && [[ ! -d $_1 ]] && echo "$_1 not found" && return
    [[ -z $2 ]] && echo "Missing destination filename" && return

    _path=$(dirname -- "$_1")
    _target="${_path%/}/$_2"

    [[ -d $_target ]] || [[ -f $_target ]] && echo "$_target already exists" && return

    cp -rp "$_1" "$_target"
    l "${_path%/}"
}
# duplicate a file/folder without retyping destination path, usage: dup [source] [new name]
alias dup='duplicate_file $1 $2'



####################
# group: variables #
####################

alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%d-%m-%Y %T"'
alias monip='curl ipinfo.io/ip && echo '
alias pass='openssl rand -base64 20'


####################
# group: web admin #
####################

# go to Apache's sites availble
alias available='cd /etc/apache2/sites-available && ll'
# go to Apache's sites enabled
alias enabled='cd /etc/apache2/sites-available && ll'
# go to vhosts root
alias vhosts='cd /var/www/vhosts && ll'
# show public key
alias pubkey='cat ~/.ssh/id_rsa.pub'
# show private key
alias privkey='cat ~/.ssh/id_rsa'


###############
# group: logs #
###############

tailforward () {
    tail -f "$@" | sed 's/\\n/\n/g';
}
# tail -f with line breaks
alias t=tailforward
alias syslog='t /var/log/syslog'
alias logmail='t /var/log/maillog'
alias logweb='t /var/www/vhosts/system/*/logs/*access*log'
alias logapache='t /var/log/apache2/**/*log'
alias lognginx='t /var/log/nginx/**/*log'
alias logphp='t /var/log/plesk-php**/*log /var/log/php*.log'
alias logmysql='t /var/log/mysql/**/*log'
alias logplesk='t /var/log/plesk/*.log'
alias logauth='t /var/log/auth.log'
# list all Plesk backups
alias logbak='cd /var/log/plesk/PMM && ll'
finduseragents () {
    awk -F\" '($2 ~ "^GET /"){print $6}' /var/www/vhosts/system/*/logs/*access*log|sort|uniq -c | less
}
# find user-agents in Apache logs
alias logUA=finduseragents



###################
# group: firewall #
###################

alias ipL='iptables -nvL --line-numbers'
alias ipS='iptables -S'
alias ipsave='service netfilter-persistent save'
alias netfilter='service netfilter-persistent save'


###############
# group: help #
###############
help () {
    echo -e 'Syntaxe des commandes fréquemment utilisées :'
    echo -e 'Pour trouver un dossier : find / -type d -name "*string*" -print'
    echo -e 'Pour trouver un fichier : find / -type f -name "*string*" -print'
    echo -e ''
    echo -e 'Pour envoyer un mail : echo test | mail -s test support@italic.fr'
    echo -e "Via sendmail : echo -e\"Subject:Objet du mail\nTest $(date '+%d/%m/%Y %H:%M:%S')\" | /usr/sbin/sendmail germain@italic.fr"
    echo -e ''
    echo -e 'Importer un dump : mysql -h localhost -u user nom_de_la_base < dump.sql'
    echo -e 'Importer dump compressé en gzip : gzip - dc < dump.sql.gz | mysql -u user nom_de_la_base'
    echo -e 'Dumper à la date du jour : mysqldump -h host -u user -P 3306 base > /base-$(date +"%Y_%m_%d_%I_%M_%S").sql'
    echo -e ''
}

# inspired by:
# https://xy2z.io/posts/2020-syncing-aliases/
# https://unix.stackexchange.com/a/132236
# https://linuxize.com/post/bash-check-if-file-exists/
# https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# https://askubuntu.com/questions/1010310/cutting-all-the-characters-after-the-last
# https://snippets.aktagon.com/snippets/807-how-to-extract-all-unique-user-agents-from-an-apache-log-with-awk
# https://stackoverflow.com/questions/6473766/syntax-error-near-unexpected-token-in-r
# https://askubuntu.com/questions/1170928/syntax-error-near-unexpected-token-after-editing-bashrc
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# https://unix.stackexchange.com/questions/519013/assign-the-same-string-to-multiple-variables
# https://edoras.sdsu.edu/doc/sed-oneliners.html
# https://opensource.com/article/19/7/bash-aliases
# https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
# https://bytefreaks.net/gnulinux/bash/how-to-remove-prefix-and-suffix-from-a-variable-in-bash
# https://serverfault.com/questions/126407/display-n-characters-as-newlines-when-using-tail
# https://unix.stackexchange.com/questions/308846/how-to-find-total-filesize-grouped-by-extension

# todo:
# https://github.com/cykerway/complete-alias
# https://unix.stackexchange.com/questions/4219/how-do-i-get-bash-completion-for-command-aliases
# https://gist.github.com/sebnyberg/92587e2423feabc02156e600781e90ac