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
    test -e $HOME/.config/iterm2/.iterm2_shell_integration.zsh && source $HOME/.config/iterm2/.iterm2_shell_integration.zsh || true
fi

### Keybindings ################################################################
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Jump word left/right
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word

    # Ctrl+Backspace delete previous word
    bindkey '^H' backward-kill-word
fi

### Claude Code: two subscriptions #############################################
# `claude` runs on the work subscription with its config in ~/.claude.
# `klaude` runs the same program on a personal subscription, with its
# own config dir ~/.claude-personal, so both can run at the same time.
#
# Kept separate per account, so sessions of one never touch the other's:
# login and account (.claude.json), session transcripts and history (/resume),
# caches, org policy files.
#
# Shared with ~/.claude, so either account can continue the other's work:
#   plans/                     a symlink; each session writes its own plan file
#   projects/<project>/memory  a symlink per project; two sessions in the same
#                              project may both edit MEMORY.md, so avoid working
#                              on one project with both accounts at once
#   settings.json              read with --settings rather than a symlink: a
#                              program that saves a file by writing a new one
#                              replaces a symlink with an ordinary file
#
# The links are made on every launch, so a new machine needs nothing else.

# Make $2 a symlink to the shared directory $1. An empty directory at $2 is
# replaced; one with files is left alone with a warning, so nothing is lost.
_claude_share_dir() {
    local shared=$1 link=$2
    [[ -L $link ]] && return
    mkdir -p "$shared" "${link:h}"
    if [[ -d $link ]]; then
        local files=("$link"/*(DN))
        if (( $#files )); then
            print -u2 "klaude: $link has files; move them into $shared, then delete it"
            return
        fi
        rmdir "$link"
    fi
    ln -s "$shared" "$link"
}

klaude() {
    local main=$HOME/.claude personal=$HOME/.claude-personal
    _claude_share_dir "$main/plans" "$personal/plans"

    # Claude Code keys a project's memory by its git repo root (worktrees use
    # the main repo's), or the current dir outside git, with every character
    # other than a letter or digit replaced by "-".
    local root dir
    root=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) && root=${root:h} || root=$PWD
    mkdir -p "$main/projects/${root//[^A-Za-z0-9]/-}/memory"
    for dir in "$main"/projects/*/memory(N/); do
        _claude_share_dir "$dir" "$personal/projects/${dir:h:t}/memory"
    done

    local settings=()
    [[ -f $main/settings.json ]] && settings=(--settings "$main/settings.json")
    CLAUDE_CONFIG_DIR=$personal command claude "${settings[@]}" "$@"
}

### AirPods utility for quick connect / disconnect #############################
# Requires: brew install blueutil coreutils
# Find device addresses with: blueutil --paired

# Bluetooth devices
AIRPODS_BT_ADDRESS="74-77-86-6d-d5-a9"
AIRPODS_NAME="🍤 shrimps"

# Configuration
BT_STATUS_COLUMN=36
BT_COMMAND_END_COLUMN=24
BT_TIMEOUT=8

# Render Bluetooth status

bt_status() {
  local name="$1"
  local message="$2"
  local color="$3"
  local first="${4:-0}"

  local width=24
  local padding=$((width - ${#name}))
  local dot_color="#858A93"
  local dots="" leading_dots=""
  local i

  (( padding < 3 )) && padding=3

  # Dots between device name and status
  for (( i = 0; i < padding - 2; i++ )); do
    dots+="·"
  done

  if [[ -t 1 ]] && (( COLUMNS >= BT_STATUS_COLUMN + 55 )); then
    (( first )) && printf '\033[1A'

    # Dots between command and device name
    local gap=$((BT_STATUS_COLUMN - BT_COMMAND_END_COLUMN - 2))

    if (( gap > 0 )); then
      for (( i = 0; i < gap; i++ )); do
        leading_dots+="·"
      done

      printf '\r\033[%dG' "$BT_COMMAND_END_COLUMN"
      print -Pn " %F{$dot_color}${leading_dots}%f "
    fi

    # Position device name at fixed column
    printf '\033[%dG\033[0K' "$BT_STATUS_COLUMN"
  else
    printf '\r\033[2K'
  fi

  # Bold device name
  print -Pn "%B${name}%b"

  # Subtle dotted separator
  print -Pn " %F{$dot_color}${dots}%f "

  # Colored status
  print -Pn "%F{$color}${message}%f"
}

# Read connection state with a timeout
bt_get_state() {
  local address="$1"

  gtimeout -k 0.2s 1s \
    blueutil --is-connected "$address" 2>/dev/null
}

# Stop and reap a background Bluetooth operation
bt_stop() {
  local pid="$1"

  kill -KILL "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null

  return 0
}

# Toggle Bluetooth connection
bt_toggle() {
  setopt local_options no_monitor

  local address="$1"
  local name="${2:-Bluetooth device}"
  local state action expected result
  local operation_pid
  local -i missing=0
  local -i verified=0
  local -i saw_valid_state=0
  local -F deadline

  # Check dependencies
  if ! command -v blueutil &>/dev/null; then
    print -P "%F{red}✗ Missing dependency: blueutil%f"
    print -r -- "  brew install blueutil"
    missing=1
  fi

  if ! command -v gtimeout &>/dev/null; then
    print -P "%F{red}✗ Missing dependency: coreutils%f"
    print -r -- "  brew install coreutils"
    missing=1
  fi

  (( missing )) && return 1

  if [[ -z "$address" ]]; then
    print -P "%F{red}✗ No Bluetooth address provided%f"
    return 1
  fi

  if ! zmodload zsh/datetime 2>/dev/null; then
    print -P "%F{red}✗ Cannot load zsh/datetime%f"
    return 1
  fi

  # Determine current state
  if ! state=$(bt_get_state "$address"); then
    bt_status "$name" "? Unknown" 214 1
    print
    return 1
  fi

  case "$state" in
    1)
      action="--disconnect"
      expected=0
      bt_status "$name" "~ Disconnecting" 245 1
      ;;
    0)
      action="--connect"
      expected=1
      bt_status "$name" "~ Connecting" yellow 1
      ;;
    *)
      bt_status "$name" "? Unknown" 214 1
      print
      return 1
      ;;
  esac

  # Start operation asynchronously
  blueutil "$action" "$address" >/dev/null 2>&1 &
  operation_pid=$!

  # Poll until state changes or timeout expires
  deadline=$(( EPOCHREALTIME + BT_TIMEOUT ))

  while (( EPOCHREALTIME < deadline )); do
    if result=$(bt_get_state "$address"); then
      if [[ "$result" == "0" || "$result" == "1" ]]; then
        saw_valid_state=1

        if [[ "$result" == "$expected" ]]; then
          verified=1
          break
        fi
      fi
    fi

    sleep 0.25
  done

  # Clean up the background operation, even if it hung
  bt_stop "$operation_pid"

  # One final verification if polling didn't confirm success
  if (( ! verified )); then
    if result=$(bt_get_state "$address"); then
      if [[ "$result" == "0" || "$result" == "1" ]]; then
        saw_valid_state=1
        [[ "$result" == "$expected" ]] && verified=1
      fi
    fi
  fi

  # Display final status
  if (( verified )); then
    if [[ "$expected" == 1 ]]; then
      bt_status "$name" "✓ Connected" green
    else
      bt_status "$name" "○ Disconnected" 245
    fi
    print
    return 0
  fi

  if (( saw_valid_state )); then
    bt_status "$name" "✗ Timed out" red
  else
    bt_status "$name" "? Unknown" 214
  fi

  print
  return 1
}

# Device shortcuts
airpods() {
  bt_toggle "$AIRPODS_BT_ADDRESS" "$AIRPODS_NAME"
}

# keyboard() {
#   bt_toggle "$KEYBOARD_BT_ADDRESS" "Magic Keyboard"
# }

### Machine-specific overrides (untracked) #####################################
[[ -f $ZDOTDIR/.zshrc.local ]] && source $ZDOTDIR/.zshrc.local
