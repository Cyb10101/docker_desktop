#!/usr/bin/env bash

COLOR_RESET=$(echo -en '\001\033[0m\002')
COLOR_RED=$(echo -en '\001\033[00;31m\002')
COLOR_GREEN=$(echo -en '\001\033[00;32m\002')
COLOR_YELLOW=$(echo -en '\001\033[00;33m\002')
COLOR_BLUE=$(echo -en '\001\033[00;34m\002')
COLOR_MAGENTA=$(echo -en '\001\033[00;35m\002')
COLOR_PURPLE=$(echo -en '\001\033[00;35m\002')
COLOR_CYAN=$(echo -en '\001\033[00;36m\002')
COLOR_LIGHTGRAY=$(echo -en '\001\033[00;37m\002')
COLOR_LRED=$(echo -en '\001\033[01;31m\002')
COLOR_LGREEN=$(echo -en '\001\033[01;32m\002')
COLOR_LYELLOW=$(echo -en '\001\033[01;33m\002')
COLOR_LBLUE=$(echo -en '\001\033[01;34m\002')
COLOR_LMAGENTA=$(echo -en '\001\033[01;35m\002')
COLOR_LPURPLE=$(echo -en '\001\033[01;35m\002')
COLOR_LCYAN=$(echo -en '\001\033[01;36m\002')
COLOR_WHITE=$(echo -en '\001\033[01;37m\002')

# Set Terminal title
function userTerminalTitle {
    echo -e '\033]2;'$1'\007'
}

# Set Terminal title - current folder
function userTerminalTitlePwd {
    echo -e '\033]2;'$(pwd)'\007'
}

# Set current user color
function userColorUser {
    if [[ $EUID -eq 0 ]]; then
        echo "${COLOR_LRED}";
    else
        echo "${COLOR_LGREEN}";
    fi
}

# Render Git branch for PS1
function renderGitBranch {
    if hash git 2>/dev/null; then
      if [ ! -z "${__git_ps1}" ]; then
        echo "${COLOR_YELLOW}$(__git_ps1)"
      fi
    fi
}

# Style bash prompt
function stylePS1 {
    VAR_HOSTNAME=`hostname`
    if [ ! -z "$1" ] || [ "$1" != "" ]; then
        VAR_HOSTNAME="${1}"
    fi;

    PS1='$(userTerminalTitlePwd)'
    PS1+='${COLOR_CYAN}['
    PS1+='$(userColorUser)\u${COLOR_CYAN}@${COLOR_LBLUE}${VAR_HOSTNAME}${COLOR_CYAN}: ${COLOR_RESET}\w'
    PS1+='${COLOR_CYAN}]'
    PS1+='$(renderGitBranch)${COLOR_CYAN}> $(userColorUser)\n\$${COLOR_RESET} ';
}

# Style bash prompt
function bashCompletion {
  if hash git 2>/dev/null; then
      source /usr/share/bash-completion/completions/git
      source /etc/bash_completion.d/git-prompt
  fi
}

# Shortcuts in bash
function addAlias {
    # color grep
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    # ls
    alias l='ls -CF --color=auto'
    alias la='ls -A --color=auto'
    alias ll='ls -ahlF --color=auto'
    alias ls='ls --color=auto'

    # cd
    alias ..='cd ..'
    alias cd..='cd ..'

    # get current unixtime
    alias unixtime='date +"%s"'

    # show all open ports
    alias ports='netstat -tulanp'

    # less defaults
    alias less='less -FSRX'
}
