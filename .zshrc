######## Oh My ZSH! config #####################################################
plugins=(colored-man-pages web-search rand-quote z)
export ZSH="/Users/alexandrucristiean/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

### Personal taste #############################################################
autoload -U colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt globdots                                       # Autocomplete dot files

### Change Directory shortcuts #################################################
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"

### Open stuff with apps ######################################################
alias vimm="open -a MacVim"                           # Use: $ vimm .zshrc
alias code="open -a 'Visual Studio Code'"             # Use: $ code ~/Documents

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
function camp {                                       # commit all message push
    ARGS=; for arg in $@; do ARGS="$ARGS$arg "; done
    commit -am "$ARGS"; push                          # Use: $ camp Fix spelling
    unset ARGS }

### Weather ####################################################################
function weather {
    ARGS=; for arg in $@; do ARGS="$ARGS$arg "; done
    curl http://wttr.in/"$ARGS";                      # Use: $ weather Palo Alto
    unset ARGS }

### Shell integration https://www.iterm2.com/documentation-shell-integration.html
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
