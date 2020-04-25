######## Oh My ZSH! config #####################################################
plugins=(colored-man-pages web-search rand-quote z)
export ZSH="/Users/alexandrucristiean/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

### Personal taste #############################################################
#autoload -U colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt globdots                                       # Autocomplete dot files

### Change Directory shortcuts #################################################
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"

### Open stuff with apps ######################################################
alias code="open -a 'Visual Studio Code'"             # Use: $ code ~/Documents
alias vimm="open -a MacVim"                           # Use: $ vimm .zshrc
alias colab="open https://colab.research.google.com"
alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
alias jupyter-colab="jupyter notebook --no-browser --port=8888 \
                    --NotebookApp.port_retries=0 \
                    --NotebookApp.notebook_dir='~/colab/local/' \
                    --NotebookApp.allow_origin='https://colab.research.google.com'"

### Git ########################################################################
function camp { git commit -am "$*"; git push }       # Use: $ camp fix bug
function clone { git clone https://github.com/$1 }    # Use: $ clone user/repo

### Weather ####################################################################
function weather { curl http://wttr.in/"$*" }         # Use: $ weather Palo Alto

### Shell integration # https://iterm2.com/documentation-shell-integration.html #
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
