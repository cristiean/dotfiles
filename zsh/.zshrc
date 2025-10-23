### Personal taste #############################################################
autoload -U colors && colors
export PS1="%B%{$fg[yellow]%}%~%{$reset_color%}%b $ "
setopt autocd                                   # cd without "cd"
setopt noclobber                                # Prevent file overwriting
setopt correct                                  # Spelling correction for cmds
setopt globdots                                 # Match w/o explicit "."
setopt interactivecomments                      # Inline # comments

# ls aliases ###################################################################
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    alias ls="ls -GFh"
else
    # Linux/Ubuntu
    alias ls="ls --color=auto -h"
fi
alias ll="ls -oa" # List files and directories

### Source Vim config from custom location #####################################
[ ! -L ~/.vimrc ] && ln -s ~/.config/.vimrc ~/.vimrc

### Open with app ##############################################################
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific aliases
    alias code="open -a 'Visual Studio Code'"       # Use: $ code [<PATH>] 
    alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
fi

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
# Cross-platform pip completion
if command -v pip3 >/dev/null 2>&1; then
    eval "$(pip3 completion --zsh 2>/dev/null)" || true
elif command -v pip >/dev/null 2>&1; then
    eval "$(pip completion --zsh 2>/dev/null)" || true
fi

### Activate z ################################################################# 
# Cross-platform z activation
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS with Homebrew
    if command -v brew >/dev/null 2>&1; then
        . `brew --prefix`/etc/profile.d/z.sh 2>/dev/null || true
    fi
else
    # Linux/Ubuntu - install z via package manager or manual installation
    if [ -f /usr/share/z/z.sh ]; then
        . /usr/share/z/z.sh
    elif [ -f /usr/local/share/z/z.sh ]; then
        . /usr/local/share/z/z.sh
    elif [ -f ~/.zsh/z.sh ]; then
        . ~/.zsh/z.sh
    fi
fi

# ### Add OpenJDK to environment ################################################
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     # macOS with Homebrew
#     if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
#         export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
#         export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
#     fi
# else
#     # Linux/Ubuntu - detect Java installation
#     if [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
#         export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
#         export PATH="$JAVA_HOME/bin:$PATH"
#     elif [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
#         export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
#         export PATH="$JAVA_HOME/bin:$PATH"
#     fi
# fi

### Terminal Integration #######################################################
# macOS iTerm2 integration
if [[ "$OSTYPE" == "darwin"* ]]; then
    test -e /Users/alexandru/.config/iterm2/.iterm2_shell_integration.zsh && source /Users/alexandru/.config/iterm2/.iterm2_shell_integration.zsh || true
fi

### Keybindings ################################################################
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Jump word left/right
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word

    # Ctrl+Backspace delete previous word
    bindkey '^H' backward-kill-word
fi