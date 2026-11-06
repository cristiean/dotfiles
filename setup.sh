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

set -euo pipefail

REPO=https://github.com/cristiean/dotfiles.git          # pull: public, no login
PUSH_URL=git@github-dotfiles:cristiean/dotfiles.git     # push: deploy key over SSH
DEPLOY_KEY=$HOME/.ssh/dotfiles_ed25519
DOTFILES=$HOME/.config

step() { print -P "\n%F{blue}%B==> $1%b%f" }
note() { print -P "    $1" }
warn() { print -P "    %F{yellow}! $1%f" }

# Push access through a GitHub deploy key: an SSH key that can reach this one
# repo and nothing else, so no GitHub account is logged in on this Mac.
# Work git hosts (GitLab etc.) use their own keys; this doesn't touch them.
push_access() {
    step "Push access to cristiean/dotfiles from this Mac"
    git -C $DOTFILES rev-parse --verify --quiet HEAD &>/dev/null ||
        { warn "Run setup.sh without options first"; exit 1 }

    mkdir -p -m 700 $HOME/.ssh
    if [[ ! -f $DEPLOY_KEY ]]; then
        note "Creating ${DEPLOY_KEY/#$HOME/~}. Set a passphrase; the Keychain remembers it."
        ssh-keygen -q -t ed25519 -f $DEPLOY_KEY -C "dotfiles deploy key, $(scutil --get ComputerName)"
        ssh-add -q --apple-use-keychain $DEPLOY_KEY || warn "Couldn't add the key to the Keychain"
    fi

    # An SSH host alias, so this key is used for the dotfiles repo only
    if ! grep -qx 'Host github-dotfiles' $HOME/.ssh/config 2>/dev/null; then
        cat >> $HOME/.ssh/config <<'EOF'

# Push access to cristiean/dotfiles only (GitHub deploy key; see ~/.config/setup.sh)
Host github-dotfiles
    HostName github.com
    User git
    IdentityFile ~/.ssh/dotfiles_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
EOF
        chmod 600 $HOME/.ssh/config
    fi

    git -C $DOTFILES remote set-url --push origin $PUSH_URL
    note "git pulls over https and pushes over SSH with this key"

    pbcopy < $DEPLOY_KEY.pub
    note "Public key, copied to the clipboard (not secret, safe to send to yourself):"
    print -r -- "    $(cat $DEPLOY_KEY.pub)"
    note "Add it at https://github.com/cristiean/dotfiles/settings/keys/new"
    note "  Title: this Mac's name. Tick 'Allow write access'."
    note "Then check it with: ssh -T git@github-dotfiles"
    note "Remove the key there when you stop using this Mac."
}

[[ $OSTYPE == darwin* ]] || { print "setup.sh is for macOS only"; exit 1 }

case ${1:-} in
    --push-access) push_access; exit ;;
    "") ;;
    *) print "usage: setup.sh [--push-access]"; exit 1 ;;
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

# 6. macOS settings. Most take effect after logging out and back in.
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
if [[ -z $(git -C $DOTFILES config --get remote.origin.pushurl) ]]; then
    note "To push dotfiles changes from this Mac: ~/.config/setup.sh --push-access"
fi
