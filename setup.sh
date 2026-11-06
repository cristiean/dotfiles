#!/bin/zsh
# Set up a Mac from these dotfiles. Safe to re-run: every step checks first.
#
# On a new Mac, in Terminal:
#   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cristiean/dotfiles/master/setup.sh)"
#
# Or, once ~/.config is cloned:
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
brew_bin=/opt/homebrew/bin/brew                 # Apple silicon
[[ $(uname -m) == x86_64 ]] && brew_bin=/usr/local/bin/brew   # Intel
if [[ ! -x $brew_bin ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$($brew_bin shellenv)"
note "$(brew --version | head -1)"

# 2. Dotfiles into ~/.config. If ~/.config already has files, they are kept;
#    the checkout stops instead of overwriting any of them.
step "Dotfiles in $DOTFILES"
if [[ -d $DOTFILES/.git ]]; then
    if [[ -z $(git -C $DOTFILES status --porcelain --untracked-files=no) ]]; then
        git -C $DOTFILES pull --ff-only --quiet && note "Up to date"
    else
        warn "Uncommitted changes in $DOTFILES; skipping pull"
    fi
else
    mkdir -p $DOTFILES
    git -C $DOTFILES init --quiet
    git -C $DOTFILES remote add origin $REPO
    git -C $DOTFILES fetch --quiet origin master
    if ! git -C $DOTFILES checkout --quiet -b master --track origin/master; then
        rm -rf $DOTFILES/.git
        warn "Move the files listed above out of $DOTFILES, then re-run setup.sh"
        exit 1
    fi
    note "Cloned $REPO"
fi

# 3. ~/.zshenv points zsh at ~/.config/zsh for the rest of its config
step "zsh"
stub=$DOTFILES/zsh/.zshenv-to-place-in-root
if ! cmp -s $stub $HOME/.zshenv; then
    [[ -f $HOME/.zshenv ]] && mv $HOME/.zshenv $HOME/.zshenv.backup && warn "Old ~/.zshenv moved to ~/.zshenv.backup"
    cp $stub $HOME/.zshenv
fi
note "~/.zshenv -> ZDOTDIR=~/.config/zsh"

# 4. Apps and CLIs
step "Brewfile"
brew bundle --file=$DOTFILES/Brewfile || warn "Some packages failed; re-run setup.sh or brew bundle later"

# 5. iTerm2 loads its settings from ~/.config/iterm2
step "iTerm2"
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
note "Settings folder: ~/.config/iterm2 (restart iTerm2 if it is open)"

# 6. GitHub login, so git can push over https
step "GitHub"
if gh auth status &>/dev/null; then
    note "Already logged in"
else
    gh auth login --git-protocol https --web
fi
gh auth setup-git

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
# Keyboard: fastest key repeat, shortest delay
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
