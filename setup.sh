#!/bin/zsh
# Set up a Mac from these dotfiles. Safe to re-run: every step checks first.
#
# The repo is private, so GitHub login comes before the clone. On a new Mac:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#   eval "$(/opt/homebrew/bin/brew shellenv)"
#   brew install gh && gh auth login --git-protocol https --web
#   zsh -c "$(gh api repos/cristiean/dotfiles/contents/setup.sh -H 'Accept: application/vnd.github.raw')"
#
# Once ~/.config is cloned, re-run any time to pull and apply changes:
#   ~/.config/setup.sh

set -euo pipefail

REPO=https://github.com/cristiean/dotfiles.git
DOTFILES=$HOME/.config

step() { print -P "\n%F{blue}%B==> $1%b%f" }
note() { print -P "    $1" }
warn() { print -P "    %F{yellow}! $1%f" }

[[ $OSTYPE == darwin* ]] || { print "setup.sh is for macOS only"; exit 1 }

# 1. Homebrew (also installs the Xcode Command Line Tools, which provide git)
step "Homebrew"
brew_bin=/opt/homebrew/bin/brew                               # Apple silicon
[[ $(uname -m) == x86_64 ]] && brew_bin=/usr/local/bin/brew   # Intel
if [[ ! -x $brew_bin ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$($brew_bin shellenv)"
note "$(brew --version | head -1)"

# 2. GitHub login. Git then authenticates through gh, which the clone needs.
step "GitHub"
command -v gh >/dev/null || brew install gh
if gh auth status &>/dev/null; then
    note "Logged in"
else
    gh auth login --git-protocol https --web
fi
gh auth setup-git

# 3. Dotfiles into ~/.config. Files already there (e.g. gh's own config) are
#    kept; if one would be overwritten, the checkout stops and changes nothing.
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

# 4. ~/.zshenv points zsh at ~/.config/zsh for the rest of its config
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

# 5. Apps and CLIs
step "Brewfile"
brew bundle --file=$DOTFILES/Brewfile || warn "Some packages failed; re-run setup.sh or brew bundle later"

# 6. iTerm2 loads its settings from ~/.config/iterm2
step "iTerm2"
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
note "Settings folder: ~/.config/iterm2 (restart iTerm2 if it is open)"

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
note "Then finish the manual steps in the setup guide (app permissions, licenses)."
