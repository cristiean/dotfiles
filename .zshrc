######## Settings left from the default OMZSH config file ######################
# Path to your oh-my-zsh installation.
COMPLETION_WAITING_DOTS="true"
ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"

ZSH_THEME="bira"

export ZSH="/Users/alexandrucristiean/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

######## ALEXANDRU's STUFF #####################################################
### Change Directory shortcuts #################################################
alias desktop="cd ~/Desktop"
alias root="cd ~/"
alias ..="cd .."

### Git ########################################################################
alias add="git add"
alias branch="git branch"
alias checkout='git checkout'
alias commit="git commit"
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
