# prefered editor
export EDITOR="nano"
export VISUAL="nano"

# allow sudo with aliases
alias sudo='sudo '

# aliases mngmt
alias als='source ~/.bash_aliases'
alias aliases='als && al'
alias al='compgen -a'

# shortcuts - lists
alias l='ls -F --color=auto --group-directories-first'
alias ll="ls -lhaF --color=always --group-directories-first | awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
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

# redefine commands
alias mkdir='mkdir -p'
alias grep='grep --color'
alias ping='ping -c 3'
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias cp='rsync -ah --info=progress2'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# variables
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%d-%m-%Y %T"'
alias monip="curl ipinfo.io/ip && echo "
alias pass="openssl rand -base64 20"

# web
alias vhosts='cd /var/www/vhosts'
alias maillog='tail -f /var/log/mail*'
alias weblog='tail -f /var/www/vhosts/system/*/logs/*access*log'
alias backuplog='cd /var/log/plesk/PMM && ll'
