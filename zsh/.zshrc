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

### Link dotfiles that must live in ~ ##########################################
# Skipped if the file already exists, so a real ~/.vimrc is never replaced.
[[ -e ~/.vimrc || -L ~/.vimrc ]] || ln -s ~/.config/.vimrc ~/.vimrc
[[ -e ~/.hushlogin || -L ~/.hushlogin ]] || ln -s ~/.config/.hushlogin ~/.hushlogin  # no "Last login"

### Open with app ##############################################################
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific aliases
    alias latex-symbols="open https://oeis.org/wiki/List_of_LaTeX_mathematical_symbols"
fi

### Python #####################################################################
alias activate="source ./.venv/bin/activate"

### Git ########################################################################
function camp { git commit -am "$*"; git push } # Use: $ camp fix bug
function clone { git clone git@github.com:$1 }  # Use: $ clone user/repo

# repo [-n] [file-or-folder]: open this repo's web page at the current branch and
# folder (or at the given file or folder). Works for GitHub, GitLab (including a
# company's own server) and SSH aliases from ~/.ssh/config. -n only prints the link.
repo() {
    emulate -L zsh
    local print_only=0
    [[ $1 == -n ]] && { print_only=1; shift }
    git rev-parse --is-inside-work-tree &>/dev/null ||
        { print -u2 "repo: not inside a git repository"; return 1 }

    # The remote branch this branch tracks; without one, origin and the local name
    local remote branch upstream
    if upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
        remote=${upstream%%/*} branch=${upstream#*/}
    else
        remote=origin branch=$(git branch --show-current)
        [[ -n $branch ]] || branch=$(git rev-parse HEAD)            # detached HEAD
        print -u2 "repo: '$branch' isn't pushed (no upstream), so its page may not exist yet"
    fi
    local remote_url
    remote_url=$(git remote get-url $remote 2>/dev/null) ||
        { print -u2 "repo: no remote called '$remote'"; return 1 }

    # Host and repo path from https://host/a/b.git, git@host:a/b.git or ssh://git@host:22/a/b.git
    local u=$remote_url host repo_path
    case $u in
        http(s|)://*) u=${u#*://}; u=${u#*@}; host=${u%%/*}; repo_path=${u#*/} ;;
        ssh://*)      u=${u#ssh://}; u=${u#*@}; host=${u%%/*}; host=${host%%:*}; repo_path=${u#*/} ;;
        *:*)          u=${u#*@}; host=${u%%:*}; repo_path=${u#*:} ;;
        *)            print -u2 "repo: can't make a web link from $remote_url"; return 1 ;;
    esac
    repo_path=${${repo_path%/}%.git}
    if [[ $remote_url != http* ]]; then                  # SSH alias -> its real host name
        local real=$(ssh -G $host 2>/dev/null | awk '$1 == "hostname" { print $2; exit }')
        [[ -n $real ]] && host=$real
    fi

    # Folder (or the given file/folder) relative to the repo root
    local kind=tree sub=$(git rev-parse --show-prefix)
    if [[ -n $1 ]]; then
        [[ -e $1 ]] || { print -u2 "repo: no such file or folder: $1"; return 1 }
        local top=$(git rev-parse --show-toplevel) abs=${1:A}
        sub=${${abs#$top}#/}
        [[ -f $1 ]] && kind=blob
    fi

    local sep=/; [[ $host == *gitlab* ]] && sep=/-/      # GitLab: /-/tree/...
    local link="https://$host/$repo_path$sep$kind/$branch/$sub"
    link=${${link// /%20}//\#/%23}
    print -r -- $link
    (( print_only )) && return
    if (( $+commands[open] )); then open $link; else xdg-open $link; fi
}

### Weather ####################################################################
function weather { curl http://wttr.in/"$*" }   # Use: $ weather Palo Alto

### Auto completions ###########################################################
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-separator '#'
zstyle ':completion:*' auto-description 'specify: %d'
# Smart case: lowercase matches either case (d -> Desktop, Dev, docs), but an
# uppercase letter only matches uppercase. Typing - also matches _.
zstyle ':completion:*' matcher-list 'm:{a-z\-}={A-Z\_}' \
    'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
    'r:|?=** m:{a-z\-}={A-Z\_}'

# Command names: your own shortcuts first, the long list of external commands
# last, zsh plumbing out of the way.
# Groups listed in this order; variables and keywords only when nothing else matches.
zstyle ':completion:*:*:-command-:*:*' group-order \
    aliases functions local-directories builtins commands
zstyle ':completion:*:*:-command-:*:*' tag-order \
    'aliases functions local-directories builtins commands'
# Hide helper functions: zsh/plugin hooks (_*, azhw:*, add-zsh-hook), iTerm2's
zstyle ':completion:*:functions' ignored-patterns \
    '_*' '*:*' 'add-zle-hook-widget' 'add-zsh-hook' 'iterm2_*'

zstyle ':completion:*' format $fg[blue]%B%U%d%u%b
zstyle ':completion:*:warnings' format "$fg[red]No matches found"
zstyle ':completion*:default' menu yes select

zmodload -i zsh/complist
bindkey -M menuselect '^M' .accept-line
bindkey '^[[Z' reverse-menu-complete

autoload -Uz compinit && compinit

### iTerm2 tools ##############################################################
# imgcat (show an image in the terminal), imgls, it2dl (download a file from a
# remote shell), it2copy, ... ship inside iTerm2.app, so they're always current.
[[ -d /Applications/iTerm.app/Contents/Resources/utilities ]] &&
    path+=(/Applications/iTerm.app/Contents/Resources/utilities)

### iTerm2 status bar ##########################################################
# The status bar shows \(user.pwd): this shell's folder, with ~ for home. It's an
# Interpolated String component because iTerm2's Current Directory component
# always draws a folder icon. Shell integration calls this at every prompt.
iterm2_print_user_vars() {
    iterm2_set_user_var pwd "${PWD/#$HOME/~}"
}

### Keybindings ################################################################
# Jumps and deletes, like in a macOS text field. The terminal turns the keys
# into codes; terminals differ, so each key is bound in every form it arrives in.
#   Cmd+←/→      line start/end      Opt+←/→       word back/forward
#   Cmd+Delete   delete the line     Opt+Delete    delete the word before
# iTerm2's profile sends ^A ^E ^U, Esc b/f and Esc+Delete, which zsh's emacs keys
# already handle. Terminal.app can't send Cmd keys to the shell: there, Ctrl+A,
# Ctrl+E and Ctrl+U do the same.
bindkey -e                                           # emacs keys, even if $EDITOR is vim
bindkey '^[[1;3D' backward-word   '^[[1;3C' forward-word     # Opt+←/→, xterm style
bindkey '^[^[[D'  backward-word   '^[^[[C'  forward-word     # Opt+←/→, Esc + arrow
bindkey '^[[1;9D' beginning-of-line '^[[1;9C' end-of-line    # Cmd+←/→, xterm style
bindkey '^[[H'    beginning-of-line '^[[F'  end-of-line      # Home/End (Fn+←/→)
bindkey '^[[3~'   delete-char     '^[[3;3~' kill-word        # Fwd Delete, Opt+Fwd Delete
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    bindkey '^[[1;5D' backward-word '^[[1;5C' forward-word   # Ctrl+←/→
    bindkey '^H' backward-kill-word                          # Ctrl+Backspace
fi

### Shift-select ###############################################################
# Select part of the command line with Shift, like in a text field:
#   Shift+←/→  by character   Shift+Opt+←/→  by word   Shift+Cmd+←/→  to start/end
# While something is selected, typing or pasting replaces it, Delete removes it,
# Cmd+X cuts it, and any other key deselects and does its usual job.
# A selection is copied to the clipboard as you make it, so Cmd+C stays free for
# copying output with the mouse. (Shift+Cmd and Cmd+X: iTerm2 only, via its
# profile; Terminal.app keeps Cmd keys for itself.)
zle_highlight=(region:standout)

_ss_bounds() {                       # reply=(start end) of the selection
    if (( MARK < CURSOR )); then reply=($MARK $CURSOR); else reply=($CURSOR $MARK); fi
}
_ss_copy() {                         # selection -> macOS clipboard
    _ss_bounds
    (( $+commands[pbcopy] )) && print -rn -- "${BUFFER[reply[1]+1,reply[2]]}" | pbcopy
}
_ss_stop() { REGION_ACTIVE=0; zle -K main }
_ss_erase() {                        # remove the selected text, without copying it
    _ss_bounds
    BUFFER="${BUFFER[1,reply[1]]}${BUFFER[reply[2]+1,-1]}"
    CURSOR=$reply[1]
    _ss_stop
}
_ss_extend() {                       # select-<widget>: start or grow, then move
    if (( ! REGION_ACTIVE )); then
        MARK=$CURSOR REGION_ACTIVE=1
        zle -K shift-select
    fi
    zle ${WIDGET#select-}
    _ss_copy
}
_ss_cut()     { _ss_copy; _ss_erase }
_ss_replace() { _ss_erase; zle -U -- "$KEYS" }       # typed key replaces it
_ss_paste()   { _ss_erase; zle bracketed-paste }     # pasted text replaces it
_ss_other()   { _ss_stop; zle -U -- "$KEYS" }        # deselect, then handle the key
_ss_nothing() { }                                    # Cmd+X with nothing selected
for _w in _ss_cut _ss_erase _ss_replace _ss_paste _ss_other _ss_nothing; do zle -N $_w; done
for _w in backward-char forward-char backward-word forward-word beginning-of-line end-of-line; do
    zle -N select-$_w _ss_extend
done
unset _w

# Keymap while something is selected: every key deselects unless bound below
bindkey -N shift-select
bindkey -M shift-select -R '^@'-'^?' _ss_other
bindkey -M shift-select -R '\M-^@'-'\M-^?' _ss_other
bindkey -M shift-select -R ' '-'~' _ss_replace
bindkey -M shift-select '^?' _ss_erase '^H' _ss_erase '^[[3~' _ss_erase
bindkey -M shift-select '^[[200~' _ss_paste           # Cmd+V (bracketed paste)
bindkey -M shift-select '^[[120;9u' _ss_cut           # Cmd+X (iTerm2 profile)
bindkey '^[[120;9u' _ss_nothing

# Shift+arrows in every form they arrive in, in both keymaps
for _km in main shift-select; do
    bindkey -M $_km '^[[1;2D' select-backward-char  '^[[1;2C' select-forward-char
    bindkey -M $_km '^[[1;4D' select-backward-word  '^[[1;4C' select-forward-word
    bindkey -M $_km '^[^[[1;2D' select-backward-word '^[^[[1;2C' select-forward-word
    bindkey -M $_km '^[[1;10D' select-beginning-of-line '^[[1;10C' select-end-of-line
    bindkey -M $_km '^[[1;2H' select-beginning-of-line '^[[1;2F' select-end-of-line
done
unset _km

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

### Bluetooth: AirPods and keyboard ###########################################
#   airpods            connect / disconnect the AirPods
#   keyboard           re-pair the Magic Keyboard with this Mac and connect it
#                      (e.g. after switching laptops): forgets it, then pairs
# Requires: brew install blueutil coreutils, and Bluetooth access for the
# terminal app (System Settings > Privacy & Security > Bluetooth).
# Find device addresses with: blueutil --paired

# Bluetooth devices
AIRPODS_BT_ADDRESS="74-77-86-6d-d5-a9"
AIRPODS_NAME="🍤 shrimps"
KEYBOARD_BT_ADDRESS="38-09-fb-35-90-5d"
KEYBOARD_NAME="⌨️ taste"

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

keyboard() {
  bt_repair "$KEYBOARD_BT_ADDRESS" "$KEYBOARD_NAME"
}

# Is the device in this Mac's list of paired devices?
bt_is_paired() {
  blueutil --paired 2>/dev/null | grep -qi -- "${1//:/-}"
}

# Forget a device on this Mac, then pair and connect it again. A Magic Keyboard
# can show as connected yet type nothing, and only a fresh pairing fixes that.
# It stays paired to the last Mac that had it, so it only accepts this one while
# it's advertising: right after being switched off and on. While it runs, the
# command's own line shows progress, with a grey hint below it:
#   keyboard ···· ⌨️ taste ···· ○ Forgotten ······ ~ Pairing (2/10)
#     Switch ⌨️ taste off and on a few times, quickly, ...
# When it's done, the line folds to the result and the hint goes away:
#   keyboard ···· ⌨️ taste ···· ✓ Paired & connected
bt_repair() {
  local address="$1" name="${2:-Bluetooth device}"
  local dot_color="#858A93" message color
  local -i try inline=0 paired=0

  command -v blueutil &>/dev/null || { print -P "%F{red}✗ Missing dependency: blueutil%f"; return 1 }
  command -v gtimeout &>/dev/null || { print -P "%F{red}✗ Missing dependency: coreutils%f"; return 1 }
  # One line holds both statuses, so it needs a wide window; otherwise one per line
  [[ -t 1 ]] && (( COLUMNS >= BT_STATUS_COLUMN + 80 )) && inline=1

  # 1. Forget
  local forgotten="○ Forgotten"
  if bt_is_paired "$address"; then
    blueutil --disconnect "$address" &>/dev/null
    blueutil --unpair "$address" &>/dev/null      # blueutil calls this experimental
    sleep 1
    if bt_is_paired "$address"; then
      bt_status "$name" "✗ Still paired" red 1; print
      print -r -- "  Remove it in System Settings > Bluetooth: ⓘ next to it > Forget This Device."
      return 1
    fi
  else
    forgotten="○ Not paired"
  fi

  # 2. Pair and connect, retrying while the keyboard is switched off and on
  local hint="Switch $name off and on a few times, quickly, until it pairs. A Mac nearby that still has it can grab it first."
  if (( inline )); then
    print -Pn "%F{245}  ${hint//\%/%%}%f"         # grey, on the line below the command
    bt_status "$name" "$forgotten" 245 1        # back up to the command's line
    print -Pn " %F{$dot_color}······%f "
    print -n $'\e7'                             # remember where the pairing status goes
  else
    bt_status "$name" "$forgotten" 245; print
    print -P "%F{245}  ${hint//\%/%%}%f"
  fi

  for (( try = 1; try <= 10; try++ )); do
    message="~ Pairing ($try/10)"
    if (( inline )); then print -n $'\e8\e[K'; print -Pn "%F{yellow}$message%f"
    else bt_status "$name" "$message" yellow; fi
    if gtimeout --foreground 15 blueutil --pair "$address" &>/dev/null; then
      blueutil --connect "$address" &>/dev/null
      sleep 1
      [[ $(bt_get_state "$address") == 1 ]] && { paired=1; break }
    fi
    sleep 2
  done

  if (( paired )); then message="✓ Paired & connected" color=green
  else message="✗ Couldn't pair" color=red; fi
  local fallback="Plug in its cable for a few seconds, or pair it in System Settings > Bluetooth."
  if (( inline )); then
    print -n $'\e8'
    bt_status "$name" "$message" $color         # redraw the line with just the result
    print -n $'\n\e[2K'                         # clear the hint line
    (( paired )) || print -P "%F{245}  $fallback%f"
  else
    bt_status "$name" "$message" $color; print
    (( paired )) || print -P "%F{245}  $fallback%f"
  fi
  (( paired ))
}

### Machine-specific overrides (untracked) #####################################
[[ -f $ZDOTDIR/.zshrc.local ]] && source $ZDOTDIR/.zshrc.local

### Plugins ####################################################################
# zsh-autosuggestions:     grey suggestion from history as you type; → accepts
# zsh-syntax-highlighting: colors the command line (green = valid command)
# Installed via Brewfile (macOS) or apt (Linux). Highlighting must load last.
for _plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    for _dir in ${HOMEBREW_PREFIX:-/opt/homebrew}/share /usr/share; do
        [[ -f $_dir/$_plugin/$_plugin.zsh ]] && { source $_dir/$_plugin/$_plugin.zsh; break }
    done
done
unset _plugin _dir
