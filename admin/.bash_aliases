# how to install
# wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/.bash_aliases && source ~/.bash_aliases
#
# make sure you have added or uncommented this in your ~/.bashrc file :
# if [ -f ~/.bash_aliases ]; then
# . ~/.bash_aliases
# fi

# update version
export VERSION_ALIASES=9

# prefered editor
export EDITOR="nano"
export VISUAL="nano"

# allow sudo with aliases
alias sudo='sudo '

# aliases mngmt
alias als='source ~/.bash_aliases'
alias al='echo -n "Version des alias :" && echo -en "\e[1;31m $VERSION_ALIASES \e[0m" && echo -n "(tapez" && echo -en "\e[1;31m aliases \e[0m" && echo "pour mettre à jour)" && echo -e "\033[3mListe des commandes disponibles :\033[m" && compgen -a'
alias alias_sync='wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/.bash_aliases'
alias aliases='alias_sync && als && al'

# shortcuts - lists
alias l='ls -F --color=auto --group-directories-first'
alias ld='ls -Ftr --color=auto --group-directories-first'
alias ll="ls -lhaF --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
alias lld="ls -lhaFtr --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
alias lz='ls --human-readable --size -1 -S --classify'

# shortcuts - navigation
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

# shortcuts - common
alias h='history|grep'
alias untar='tar -zxvf $1'
alias tar='tar -czvf $1'
alias count='find . -type f | wc -l'
alias rel='cat /etc/*release'

# redefine commands
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias mkdir='mkdir -p'
alias grep='grep --color'
alias ping='ping -c 3'
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias cpp='rsync -ah --info=progress2'

# duplicate file, usage:
# bak ~/folder/subfolder/file.txt
# dup ~/folder/subfolder/file.txt file.sh
backup_file(){
    _path=$(dirname -- "$1")
    _target="${_path%/}/{$1}.bak"
    mv -- "$1" "$_target"
}
duplicate_file(){
    _path=$(dirname -- "$1")
    _target="${_path%/}/$2"
    mv -- "$1" "$_target"
}
alias bak='backup_file $1'
alias dup='duplicate_file $1 $2'



# variables
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%d-%m-%Y %T"'
alias monip="curl ipinfo.io/ip && echo "
alias pass="openssl rand -base64 20"

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

# inspired by:
# - https://xy2z.io/posts/2020-syncing-aliases/
# - https://unix.stackexchange.com/a/132236
