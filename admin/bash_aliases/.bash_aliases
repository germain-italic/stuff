#!/bin/bash

# how to install
# wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/bash_aliases/.bash_aliases && source ~/.bash_aliases
#
# make sure you have added or uncommented this in your ~/.bashrc file :
# if [ -f ~/.bash_aliases ]; then
# . ~/.bash_aliases
# fi
#
# how to test using Debian WSL
# germain@germain-xps:~$ ln -s /mnt/c/Users/germain/Documents/Sites/stuff/admin/bash_aliases/.bash_aliases ~/.bash_aliases
# ln -s /mnt/c/Users/germain/Documents/Sites/stuff/admin/bash_aliases/.bash_aliases ~/.bash_aliases
# germain@germain-xps:~$ source ~/.bash_aliases
#
# if your shell returns multiple errors like: -bash: $'\r': command not found
# run the command below to fix your line endings
# sed -i 's/\r//' ~/.bash_aliases

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# change the version of this file after editing it
export VERSION_ALIASES=19

# my prefered editor
export EDITOR="nano"
export VISUAL="nano"

# allow sudo to work with aliases
alias sudo='sudo '

# aliases mngmt
alias ale='$EDITOR  ~/.bash_aliases'
alias als='source ~/.bash_aliases'
alias al='echo -n "Version des alias :" && echo -en "\e[1;31m $VERSION_ALIASES \e[0m" && echo -n "(tapez" && echo -en "\e[1;31m aliases \e[0m" && echo "pour mettre à jour)" && echo -e "\033[3mListe des commandes disponibles :\033[m" && compgen -a'
alias aliases_sync='wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/bash_aliases/.bash_aliases'
alias aliases='aliases_sync && als && al'

# shortcuts - lists
alias l='ls -F --color=auto --group-directories-first'
alias ld='ls -Ftr --color=auto --group-directories-first'
alias ll="ls -lhaF --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
alias lld="ls -lhaFtr --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
alias lz='ls --human-readable --size -1 -S --classify'
alias la='ls -la'

# shortcuts - navigation
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../'
alias ......='cd ../../../../'
alias .......='cd ../../../../../'

# shortcuts - common
alias h='history|grep'
alias untar='tar -zxvf $1'
alias tar='tar -czvf $1'
alias count='find . -type f | wc -l'
alias rel='cat /etc/*release'

# redefine commands / fix typos
alias chown='chown --preserve-root'
alias chwon='chown'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias mkdir='mkdir -p'
alias grep='grep --color'
alias ping='ping -c 3'
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias cp='cp -rp'
alias cpp='rsync -ah --info=progress2'

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
alias dup='duplicate_file $1 $2'



# variables
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%d-%m-%Y %T"'
alias monip='curl ipinfo.io/ip && echo '
alias pass='openssl rand -base64 20'

# web
alias sites='cd /etc/apache2/sites-available && ll'
alias vhosts='cd /var/www/vhosts && ll'
alias maillog='tail -f /var/log/mail*'
alias mailog=maillog
alias mailogs=maillog
alias weblog='tail -f /var/www/vhosts/system/*/logs/*access*log'
alias weblogs=weblog
alias backuplog='cd /var/log/plesk/PMM && ll'
alias backuplogs=backuplog
alias bklog=backuplog
alias bklogs=backuplog
finduseragents () {
    awk -F\" '($2 ~ "^GET /"){print $6}' /var/www/vhosts/system/*/logs/*access*log|sort|uniq -c | less
}
alias uas=finduseragents

# inspired by:
# - https://xy2z.io/posts/2020-syncing-aliases/
# - https://unix.stackexchange.com/a/132236
# - https://linuxize.com/post/bash-check-if-file-exists/
# - https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty/
# - https://askubuntu.com/questions/1010310/cutting-all-the-characters-after-the-last
# - https://snippets.aktagon.com/snippets/807-how-to-extract-all-unique-user-agents-from-an-apache-log-with-awk
# - https://stackoverflow.com/questions/6473766/syntax-error-near-unexpected-token-in-r
# - https://askubuntu.com/questions/1170928/syntax-error-near-unexpected-token-after-editing-bashrc