# https://www.germain.lol/ajouts-a-mon-fichier-bashrc-bash_aliases/

###################
# ~/.bash_aliases #
###################

alias l='ls -CF'
alias ll='ls -alFh'

# si vous avez installé TheFuck
# https://github.com/nvbn/thefuck
eval $(thefuck --alias)

# si vous avez installé le wrapper de Vivek Gite pour Ping
# https://www.cyberciti.biz/tips/unix-linux-bash-shell-script-wrapper-examples.html
source $HOME/scripts/wrapper_functions.lib

# https://www.germain.lol/logs-des-requetes-sql-en-temps-reel/
alias querylog='sudo tail -f /var/log/mysql/queries.log  | sed "s/\\\n/\\n/g"'
alias errorlog='sudo tail -f /var/log/apache2/error.log  | sed "s/\\\n/\\n/g"'

# https://askubuntu.com/a/259386
shopt -s dotglob



# https://thucnc.medium.com/how-to-show-current-git-branch-with-colors-in-bash-prompt-380d05a24745
# Show git branch name
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt
