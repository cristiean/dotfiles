### Personal taste #############################################################
autoload -U colors && colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt autocd                                   # cd without "cd"
setopt noclobber                                # Prevent file overwriting
alias ls="ls -GFh"                              # Other aliases inherit options
alias l="ls -1"
alias la="ls -A"
alias lS="ls -oS"
alias ll="ls -oa"
alias ld="ls -d .*"
alias zshrc="vim ~/.zshrc"

### Open with app ##############################################################
alias code="open -a 'Visual Studio Code'"       # Use: $ code [<PATH>] 
alias colab="open https://colab.research.google.com"
alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
alias jupyter-colab="jupyter notebook --no-browser --port=8888 \
                    --NotebookApp.port_retries=0 \
                    --NotebookApp.notebook_dir='~/colab/local/' \
                    --NotebookApp.allow_origin='https://colab.research.google.com'"

### Git ########################################################################
function camp { git commit -am "$*"; git push } # Use: $ camp fix bug
function clone { git clone git@github.com:$1 }  # Use: $ clone user/repo

### Weather ####################################################################
function weather { curl http://wttr.in/"$*" }   # Use: $ weather Palo Alto

### Auto completions ###########################################################
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-separator '#'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=* m:{a-zA-Z}={A-Za-z}'

zstyle ':completion:*' format $fg[blue]%B%U%d%u%b
zstyle ':completion:*:warnings' format "$fg[red]No matches found"
zstyle ':completion*:default' menu 'select=0'

autoload -Uz compinit && compinit

### Auto suggestions ### IN TRIALS #############################################
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

### Syntax highlighting ### IN TRIALS ##########################################
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

### pip completion #############################################################
eval "$(pip completion --zsh)"
