export BASH_ENV=$HOME/.bashrc
export EDITOR=/bin/vim
export PAGER=less

alias ls="ls --color -laF"
alias df="df -H"
alias genpass="cat /dev/urandom | tr -dc A-Za-z0-9 | head -c8; echo"

shopt -s histappend
export HISTTIMEFORMAT="[%F %T] "
export HISTIGNORE="&:history:ls:[bf]g:exit"
#export HISTCONTROL="ignoredups"
export HISTCONTROL=ignorespace:erasedups
shopt -s cmdhist

SETCOLOR='\[\033[36m\]'
SETCOLOR_NORMAL='\[\033[0m\]'
SETCOLOR_HOST='\[\033[37m\]'
SETCOLOR_CENTOS='\[\033[34m\]'
SETCOLOR_UBUNTU='\[\033[33m\]'


if [ "`id -u`" = "0" ]; then
  SET_SEP="> "
  SETCOLOR_USER='\[\033[31m\]'
else
  SETCOLOR_USER='\[\033[32m\]'
  SET_SEP="$ "
fi

if [ "$(awk -F= '/^ID=/{print $2}' /etc/os-release  |sed 's|"||g')" = "centos" ]; then
  PS1="${SETCOLOR_CENTOS}[\t] ${SETCOLOR_USER}\u${SETCOLOR_HOST}@${SETCOLOR}\H \[\033[00m\](\[\033[32;1m\]\w\[\033[00m\])${SET_SEP}"
else
  PS1="${SETCOLOR_UBUNTU}[\t] ${SETCOLOR_USER}\u${SETCOLOR_HOST}@${SETCOLOR}\H \[\033[00m\](\[\033[32;1m\]\w\[\033[00m\])${SET_SEP}"
fi

unset SETCOLOR
unset SETCOLOR_NORMAL
unset SETCOLOR_HOST
