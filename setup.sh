#!/bin/zsh
# Set up a Mac from these dotfiles. Safe to re-run: every step checks first.
#
# On a new Mac, in Terminal (no GitHub login needed; the repo is public):
#   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cristiean/dotfiles/master/setup.sh)"
#
# Once ~/.config is cloned, re-run any time to pull and apply changes:
#   ~/.config/setup.sh
#
# To push dotfiles changes from this Mac (optional, per Mac):
#   ~/.config/setup.sh --push-access
#
# To link the agent skills only, without the rest of the setup:
#   ~/.config/setup.sh --skills

set -euo pipefail

REPO=https://github.com/cristiean/dotfiles.git          # pull: public, no login
PUSH_URL=git@github-dotfiles:cristiean/dotfiles.git     # push: deploy key over SSH
DOTFILES=$HOME/.config

step() { print -P "\n%F{blue}%B==> $1%b%f" }
note() { print -P "    $1" }
warn() { print -P "    %F{yellow}! $1%f" }

# Push access through a GitHub deploy key: an SSH key that can reach this one
# repo and nothing else, so no personal GitHub login is needed on a work Mac.
# bin/ssh-key does the SSH part; the key is pasted into the repo's Deploy keys
# page instead of an account's SSH keys page.
push_access() {
    step "Push access to cristiean/dotfiles from this Mac"
    git -C $DOTFILES rev-parse --verify --quiet HEAD &>/dev/null ||
        { warn "Run setup.sh without options first"; exit 1 }

    git -C $DOTFILES remote set-url --push origin $PUSH_URL
    note "git pulls over https and pushes over SSH as github-dotfiles"

    SSH_KEY_ADD_URL=https://github.com/cristiean/dotfiles/settings/keys/new \
    SSH_KEY_ADD_HINT="Title: this Mac's name. Tick 'Allow write access'. Delete it there when you stop using this Mac." \
        $DOTFILES/bin/ssh-key github.com github-dotfiles
}

# Agent skills. Each folder in ~/.config/skills is one skill; it is linked into
# the personal skills folder of Claude Code (work and personal account) and of
# Codex, so all three read the same copy.
link_skills() {
    step "Agent skills"
    local skill dir link
    for skill in $DOTFILES/skills/*(N/); do
        [[ -f $skill/SKILL.md ]] || continue
        for dir in $HOME/.claude/skills $HOME/.claude-personal/skills $HOME/.agents/skills; do
            link=$dir/${skill:t}
            if [[ -e $link && ! -L $link ]]; then
                warn "$link exists and is not a link; left as it is"
            else
                mkdir -p $dir
                ln -sfn $skill $link
            fi
        done
        note "${skill:t}"
    done
}

# Apps and CLIs. A list shows the entries of Brewfile, checked, and of
# Brewfile.develop, unchecked. You check or uncheck entries, and the choice goes
# to Brewfile.local, which `brew bundle` then installs. Brewfile.local keeps the
# unchecked entries too, as "# " lines, so the next run starts from the same
# choice. An entry that is not in Brewfile.local yet starts checked if it is in
# Brewfile or already installed.
# Returns 1 when there is nothing to install.
choose_apps() {
    emulate -L zsh
    setopt extended_glob
    local chosen=$DOTFILES/Brewfile.local
    local entry='^(brew|cask|mas|vscode|whalebrew)[[:space:]]+"([^"]+)"(.*)$'
    local line key name file default label rest count i

    # The choice from the last run: 1 for a checked entry, 0 for an unchecked one
    local -A saved
    if [[ -f $chosen ]]; then
        while IFS= read -r line; do
            [[ ${line#\# } =~ $entry ]] || continue
            key=$match[1]:$match[2]
            [[ $line == \#* ]] && saved[$key]=0 || saved[$key]=1
        done < $chosen
    fi

    # What Homebrew has installed on this Mac
    local -A installed
    for name in $(brew list --formula -1 2>/dev/null); do key=brew:$name; installed[$key]=1; done
    for name in $(brew list --cask -1 2>/dev/null); do key=cask:$name; installed[$key]=1; done

    # One row for each file name and for each entry in the file
    local -a kind text orig checked always
    for file default in $DOTFILES/Brewfile 1 $DOTFILES/Brewfile.develop 0; do
        [[ -f $file ]] || continue
        kind+=(head) text+=("${file:t}") orig+=('') checked+=(0)
        while IFS= read -r line; do
            if [[ $line =~ $entry ]]; then
                key=$match[1]:$match[2] name=$match[1]:${match[2]:t} label=$match[2] rest=$match[3]
                if [[ $rest == *\#* ]]; then            # the comment after the entry
                    (( $#label < 26 )) && label=${(r:26:)label}
                    label+=" ${${rest#*\#}## #}"
                fi
                kind+=(item) text+=("$label") orig+=("$line")
                if (( $+saved[$key] )); then checked+=($saved[$key])
                elif (( default || $+installed[$name] )); then checked+=(1)
                else checked+=(0)
                fi
            elif [[ $line != [[:space:]]#(\#*|) ]]; then
                always+=("$line")                       # tap, cask_args, ...: not a choice
            fi
        done < $file
    done
    local n=$#kind total=${#${(M)kind:#item}}
    (( total )) || { note "The Brewfiles list no apps"; return 1 }

    if [[ -t 0 && -t 1 ]]; then
        local cursor=1 top=1 height cols mark on press buf
        local -a size
        local bold=$'\e[1m' reverse=$'\e[7m' plain=$'\e[0m' eol=$'\e[K\n'
        local restore=$'\e[?7h\e[?25h\e[?1049l'
        while [[ $kind[cursor] != item ]]; do (( cursor++ )); done
        # Draw on the alternate screen, with no cursor and no line wrap. The
        # traps put the terminal back if the script stops inside the list.
        print -n '\e[?1049h\e[?25l\e[?7l'
        trap "print -rn -- '$restore'" EXIT
        trap "print -rn -- '$restore'; exit 130" INT
        while true; do
            size=(${=$(stty size </dev/tty 2>/dev/null)})
            height=$(( ${size[1]:-24} - 4 )) cols=${size[2]:-80}
            (( height < 3 )) && height=3
            (( cursor < top )) && top=$cursor
            (( cursor >= top + height )) && top=$(( cursor - height + 1 ))
            [[ $kind[cursor-1] == head ]] && (( top == cursor )) && top=$(( cursor - 1 ))
            count=${#${(M)checked:#1}}

            buf=$'\e[H'"${bold}Apps and CLIs to install on this Mac${plain}${eol}"
            buf+="↑/↓ move   space check or uncheck   a all   n none   enter install   q skip${eol}${eol}"
            for (( i = top; i < top + height; i++ )); do
                if (( i > n )); then :
                elif [[ $kind[i] == head ]]; then buf+="${bold}${text[i]}${plain}"
                else
                    (( checked[i] )) && mark='[x]' || mark='[ ]'
                    line="  $mark $text[i]"; line=$line[1,cols-1]
                    (( i == cursor )) && buf+="${reverse}${line}${plain}" || buf+=$line
                fi
                buf+=$eol
            done
            buf+="$count of $total checked"
            (( top + height <= n )) && buf+="   ↓ more"
            print -rn -- "$buf"$'\e[K\e[J'

            read -sk1 press || press=q
            if [[ $press == $'\e' ]]; then              # an arrow key sends Esc and 2 more characters
                read -sk2 -t 0.05 press || press=
                case $press in
                    ('[A'|OA) press=k ;;
                    ('[B'|OB) press=j ;;
                    (*) press= ;;
                esac
            fi
            case $press in
                (k) for (( i = cursor - 1; i >= 1; i-- )); do
                        [[ $kind[i] == item ]] && { cursor=$i; break }
                    done ;;
                (j) for (( i = cursor + 1; i <= n; i++ )); do
                        [[ $kind[i] == item ]] && { cursor=$i; break }
                    done ;;
                (' ') checked[cursor]=$(( ! checked[cursor] )) ;;
                (a|n) [[ $press == a ]] && on=1 || on=0
                    for (( i = 1; i <= n; i++ )); do
                        [[ $kind[i] == item ]] && checked[i]=$on
                    done ;;
                ($'\n'|$'\r') break ;;
                (q) print -rn -- $restore; trap - EXIT INT
                    note "Skipped: no apps installed"
                    return 1 ;;
            esac
        done
        print -rn -- $restore; trap - EXIT INT
    else
        note "Not in a terminal, so the list is not shown"
    fi

    {
        print -r -- '# The apps chosen for this Mac. setup.sh writes this file and reads it on the'
        print -r -- '# next run. A line that starts with "# " is an entry that was left unchecked.'
        (( $#always )) && print -rl -- $always
        for (( i = 1; i <= n; i++ )); do
            [[ $kind[i] == item ]] || continue
            (( checked[i] )) && print -r -- $orig[i] || print -r -- "# $orig[i]"
        done
    } > $chosen
    count=${#${(M)checked:#1}}
    note "$count of $total checked, saved in ${chosen/#$HOME/~}"
    (( count ))
}

[[ $OSTYPE == darwin* ]] || { print "setup.sh is for macOS only"; exit 1 }

case ${1:-} in
    --push-access) push_access; exit ;;
    --skills) link_skills; exit ;;
    "") ;;
    *) print "usage: setup.sh [--push-access | --skills]"; exit 1 ;;
esac

# 1. Homebrew (also installs the Xcode Command Line Tools, which provide git)
step "Homebrew"
brew_bin=/opt/homebrew/bin/brew                               # Apple silicon
[[ $(uname -m) == x86_64 ]] && brew_bin=/usr/local/bin/brew   # Intel
if [[ ! -x $brew_bin ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$($brew_bin shellenv)"
note "$(brew --version | head -1)"

# 2. Dotfiles into ~/.config. Files already there are kept; if one would be
#    overwritten, the checkout stops and changes nothing.
step "Dotfiles in $DOTFILES"
if git -C $DOTFILES rev-parse --verify --quiet HEAD &>/dev/null; then
    # Tracked files with uncommitted changes on this Mac. iTerm2 saves its
    # settings to a tracked file, so there is often one. The pull keeps these
    # changes (--autostash). If the repo changed the same file, the two versions
    # can conflict, so the pull is skipped.
    changed=(${(f)"$(git -C $DOTFILES diff --name-only HEAD)"})
    if ! git -C $DOTFILES fetch --quiet; then
        warn "Could not fetch (offline?); continuing with local files"
    else
        incoming=(${(f)"$(git -C $DOTFILES diff --name-only 'HEAD...@{u}' 2>/dev/null || true)"})
        both=(${changed:*incoming})
        if (( $#both )); then
            warn "Changed on this Mac and in the repo: $both"
            warn "Commit or discard the change here, then re-run; skipping pull"
        elif git -C $DOTFILES merge --ff-only --autostash --quiet '@{u}'; then
            note "Up to date"
        else
            warn "Could not pull (diverged); continuing with local files"
        fi
    fi
elif [[ -e $DOTFILES/.git ]]; then
    warn "$DOTFILES/.git exists but has no commits; check it, delete it, then re-run"
    exit 1
else
    mkdir -p $DOTFILES
    git -C $DOTFILES init --quiet
    git -C $DOTFILES remote add origin $REPO
    if ! git -C $DOTFILES fetch --quiet origin master ||
       ! git -C $DOTFILES checkout --quiet -b master --track origin/master; then
        rm -rf $DOTFILES/.git
        warn "Clone failed. If files are listed above, move them out of $DOTFILES; then re-run"
        exit 1
    fi
    note "Cloned $REPO"
fi
# Commits to the dotfiles always use the personal identity from git/config,
# even on a work Mac where ~/.gitconfig sets a work email.
for key in user.name user.email; do
    git -C $DOTFILES config $key "$(git config --file $DOTFILES/git/config $key)"
done
note "Dotfiles commits as $(git -C $DOTFILES config user.email)"

# 3. ~/.zshenv points zsh at ~/.config/zsh for the rest of its config
step "zsh"
stub=$DOTFILES/zsh/.zshenv-to-place-in-root
if ! cmp -s $stub $HOME/.zshenv; then
    if [[ -f $HOME/.zshenv ]]; then
        backup=$HOME/.zshenv.backup-$(date +%Y%m%d-%H%M%S)
        mv $HOME/.zshenv $backup
        warn "Old ~/.zshenv moved to $backup"
    fi
    cp $stub $HOME/.zshenv
fi
note "~/.zshenv -> ZDOTDIR=~/.config/zsh"

# 4. Apps and CLIs: the entries left checked in the list
step "Apps and CLIs"
if choose_apps; then
    brew bundle --file=$DOTFILES/Brewfile.local || warn "Some packages failed; re-run setup.sh or brew bundle later"
fi

# 5. iTerm2 loads its settings from ~/.config/iterm2
step "iTerm2"
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
note "Settings folder: ~/.config/iterm2 (restart iTerm2 if it is open)"

# BluetoothBar: menu bar icons for the AirPods and keyboard (~/.config/menubar)
"$DOTFILES/menubar/build.sh" >/dev/null && note "BluetoothBar built and started (allow Bluetooth when asked)" ||
    warn "BluetoothBar didn't build; run ~/.config/menubar/build.sh to see why"

# 6. Agent skills, linked into Claude Code and Codex
link_skills

# 7. macOS settings. Most take effect after logging out and back in.
step "macOS settings"
# Dock: auto-hide, scale effect, minimise into the app icon
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock minimize-to-application -bool true
# Mission Control: keep Spaces in a fixed order
defaults write com.apple.dock mru-spaces -bool false
# Hot corner: bottom right starts the screensaver
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0
# Finder: show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# Scroll bars only while scrolling
defaults write -g AppleShowScrollBars -string WhenScrolling
# Keyboard: fastest key repeat, shortest delay (the fastest the sliders allow)
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
# Typing: no autocorrect, auto-capitalise, double-space full stop, smart quotes/dashes
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
# Menu bar: tighter icon spacing so fewer icons hide under the notch
defaults -currentHost write -g NSStatusItemSpacing -int 6
defaults -currentHost write -g NSStatusItemSelectionPadding -int 6
killall Dock Finder 2>/dev/null || true

step "Done"
note "Open a new terminal tab to load the zsh config."
note "Log out and back in for keyboard and menu bar settings."
note "Then follow ~/.config/README.md: git login, app permissions, licenses."
if [[ -z $(git -C $DOTFILES config --get remote.origin.pushurl) ]]; then
    note "To push from this Mac, see \"Log in to git\" in the README."
fi
