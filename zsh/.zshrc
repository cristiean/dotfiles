### Personal taste #############################################################
autoload -U colors && colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt autocd                                   # cd without "cd"
setopt noclobber                                # Prevent file overwriting
setopt correct                                  # Spelling correction for cmds
setopt globdots                                 # Match w/o explicit "."
setopt interactivecomments                      # Inline # comments
alias ls="ls -GFh"                              # Other aliases inherit options
alias l="ls -1"
alias la="ls -A"
alias lS="ls -oS"
alias ll="ls -oa"
alias ld="ls -d .*"

### Load .vimrc from custom location
alias vim="vim -u ~/.config/.vimrc"  

### Open with app ##############################################################
alias code="open -a 'Visual Studio Code'"       # Use: $ code [<PATH>] 
alias colab="open https://colab.research.google.com"
alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
#alias jupyter-colab="jupyter notebook --no-browser --port=8888 \
#                    --NotebookApp.port_retries=0 \
#                    --NotebookApp.notebook_dir='~/colab/local/' \
#                    --NotebookApp.allow_origin='https://colab.research.google.com'"

### Python #####################################################################
alias activate="source ./venv/bin/activate"

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
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zstyle ':completion:*' format $fg[blue]%B%U%d%u%b
zstyle ':completion:*:warnings' format "$fg[red]No matches found"
zstyle ':completion*:default' menu yes select

zmodload -i zsh/complist
bindkey -M menuselect '^M' .accept-line
bindkey '^[[Z' reverse-menu-complete

autoload -Uz compinit && compinit

### pip completion #############################################################
eval "$(pip3 completion --zsh)"

### Activate z ################################################################# 
# . /usr/local/etc/profile.d/z.sh

### Add OpenJDK to environment ################################################
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"

### iTerm2 Shell Utilities ####################################################
test -e /Users/alexandru/.config/iterm2/.iterm2_shell_integration.zsh && source /Users/alexandru/.config/iterm2/.iterm2_shell_integration.zsh || true

