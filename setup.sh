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
    if [[ -n $(git -C $DOTFILES status --porcelain --untracked-files=no) ]]; then
        warn "Uncommitted changes in $DOTFILES; skipping pull"
    elif git -C $DOTFILES pull --ff-only --quiet; then
        note "Up to date"
    else
        warn "Could not pull (diverged or offline); continuing with local files"
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

# 4. Apps and CLIs. Dev and work tools are in Brewfile.develop, installed by hand.
step "Brewfile"
brew bundle --file=$DOTFILES/Brewfile || warn "Some packages failed; re-run setup.sh or brew bundle later"

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
