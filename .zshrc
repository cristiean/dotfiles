### Personal taste #############################################################
autoload -U colors && colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt globdots                                       # Autocomplete dot files
alias ls="ls -FG"

### Change Directory shortcuts #################################################
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"

### Open stuff with apps ######################################################
alias code="open -a 'Visual Studio Code'"             # Use: $ code ~/Documents
alias colab="open https://colab.research.google.com"
alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
alias jupyter-colab="jupyter notebook --no-browser --port=8888 \
                    --NotebookApp.port_retries=0 \
                    --NotebookApp.notebook_dir='~/colab/local/' \
                    --NotebookApp.allow_origin='https://colab.research.google.com'"

### Git ########################################################################
function camp { git commit -am "$*"; git push }       # Use: $ camp fix bug
#function clone { git clone https://github.com/$1 }    # Use: $ clone user/repo
function clone { git clone git@github.com:$1 }        # Use: $ clone user/repo

### Weather ####################################################################
function weather { curl http://wttr.in/"$*" }         # Use: $ weather Palo Alto
