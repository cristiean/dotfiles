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
alias code="open -a 'Visual Studio Code'"             # Use: $ code ~/Documents
alias vimm="open -a MacVim"                           # Use: $ vimm .zshrc

### Git ########################################################################
#alias add="git add"
#alias branch="git branch"
function camp { commit -am "$*";push }                # Use: $ camp fix bug
#alias checkout='git checkout'
function clone { git clone https://github.com/$1 }    # Use: $ clone user/repo
#alias commit="git commit"
#alias fetch="git fetch"
#alias merge="git merge"
#alias pull="git pull"
#alias push="git push"

### Weather ####################################################################
function weather { curl http://wttr.in/"$*" }         # Use: $ weather Palo Alto

### Shell integration # https://iterm2.com/documentation-shell-integration.html #
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
