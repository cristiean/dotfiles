### Personal taste #########################################################
autoload -U colors && colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt globdots                                   # Autocomplete dot files
setopt autocd                                     # cd without "cd"
setopt correct                                    # Correct commands
setopt correctall                                 # Correct commands
setopt noclobber                                  # Prevent file overwriting
alias ls="ls -FG"

### Change Directory shortcuts #############################################
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"

### Open stuff with apps ###################################################
alias code="open -a 'Visual Studio Code'"         # Use: $ code [<PATH>] 
alias colab="open https://colab.research.google.com"
alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
alias jupyter-colab="jupyter notebook --no-browser --port=8888 \
                    --NotebookApp.port_retries=0 \
                    --NotebookApp.notebook_dir='~/colab/local/' \
                    --NotebookApp.allow_origin='https://colab.research.google.com'"

### Git ####################################################################
function camp { git commit -am "$*"; git push }   # Use: $ camp fix bug
function clone { git clone git@github.com:$1 }    # Use: $ clone user/repo

### Weather ################################################################
function weather { curl http://wttr.in/"$*" }     # Use: $ weather Palo Alto

### Auto completions #######################################################
# In trial. Installed using $ brew install zsh-completions
autoload -Uz compinit && compinit -d ~/dumps/.zcompdump

### Auto suggestions #######################################################
# In trial. Installed using $ brew install zsh-autosuggestions
# Has to be at the and of .zshrc
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

### Syntax highlighting ####################################################
# In trial. Installed using $ brew install zsh-syntax-highlighting
# Has to be at the end of .zshrc
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
