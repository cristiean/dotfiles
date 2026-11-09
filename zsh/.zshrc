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

### Bluetooth: airpods, keyboard (zsh/bluetooth.zsh) ##########################
source $ZDOTDIR/bluetooth.zsh

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
