######## Settings left from the default OMZSH config file ######################
# Path to your oh-my-zsh installation.
COMPLETION_WAITING_DOTS="true"
ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"

autoload -U colors;colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "

export ZSH="/Users/alexandrucristiean/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

######## ALEXANDRU's STUFF #####################################################
### Taste ######################################################################
alias ls="ls -1"                                      # Displays one-entry lines

### Change Directory shortcuts #################################################
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"
alias root="cd ~/"
alias ..="cd .."

### Git ########################################################################
alias add="git add"
alias branch="git branch"
alias checkout='git checkout'
alias commit="git commit"
alias fetch="git fetch"
alias merge="git merge"
alias pull="git pull"
alias push="git push"
alias status="git status"
function clone { git clone https://github.com/$1; }   # Use: $ clone user/repo

### Open with MacVim ###########################################################
alias vimm="open -a MacVim"                           # Use: $ vimm .zshrc

### Open with Visual Studio Code ###############################################
alias code="open -a 'Visual Studio Code'"             # Use: $ code ~/Documents

### Weather ####################################################################
function weather {
    ARGS=; for arg in $@; do ARGS="$ARGS$arg "; done
    curl http://wttr.in/"$ARGS";                      # Use: $ weather Palo Alto
    unset ARGS;
}
################################################################################

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

