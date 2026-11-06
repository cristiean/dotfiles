# dotfiles

My macOS setup: shell, git, terminal, apps and system settings. It lives in `~/.config`, and a new Mac is set up from it with one script.

## 1. Run the setup script

On a new Mac, open Terminal and run this. No GitHub login is needed:

```sh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cristiean/dotfiles/master/setup.sh)"
```

It's safe to run again; every step checks before it acts. It:

- Installs Homebrew, with the Xcode Command Line Tools (git)
- Clones this repo to `~/.config` and writes `~/.zshenv`, so zsh loads its config from `~/.config/zsh`
- Makes commits to this repo use your personal name and email, even on a work Mac
- Installs every app and CLI in the `Brewfile`
- Points iTerm2 at `~/.config/iterm2` for its settings
- Applies the macOS settings listed under [What `setup.sh` sets](#what-setupsh-sets)

Then **log out and back in**, and open iTerm2.

Dev and work tools (Kubernetes, AWS, OrbStack, DBeaver, Claude Code) are in `Brewfile.develop`. Comment out what this Mac doesn't need, then run:

```sh
brew bundle --file=~/.config/Brewfile.develop
```

## 2. Log in to git

Git logs in with SSH keys, one per Mac and service. The `ssh-key` command creates one, copies its public key to the clipboard and prints the page to paste it into. When it asks for a passphrase, set one; the Keychain remembers it. Pasting can be done from any device, because the public key isn't secret.

**Personal Mac.** One key for your whole GitHub account, so every repo works, these dotfiles included:

```sh
ssh-key github.com                     # paste the key into your GitHub account's SSH keys page
git -C ~/.config remote set-url --push origin git@github.com:cristiean/dotfiles.git
```

The second line makes the dotfiles push with that key. Other repos just need SSH clone URLs (`git@github.com:owner/repo.git`).

**Work Mac.** Your personal GitHub account stays off it:

```sh
ssh-key gitlab.company.com             # the company's git host, with your work account
~/.config/setup.sh --push-access       # optional: lets this Mac push the dotfiles, and nothing else
```

For a company on GitHub instead, run `ssh-key github.com` and paste the key into your *work* GitHub account. `--push-access` asks you to paste its key into this repo's Deploy keys page and tick **Allow write access**.

`ssh-key` prints the exact page to paste each key into, for GitHub and for any GitLab, and a command to test the key.

On a work Mac, also set your work email for work repos. This repo keeps your personal one either way:

```sh
git config --file ~/.gitconfig user.email "you@company.com"
```

### Which key does what

- **Account key** (`ssh-key`): lets git act as you on that service, with access to every repo your account can reach.
- **Deploy key** (`--push-access`): attached to this one repo instead of an account, so it can push here and nothing else. That's why a work Mac can push dotfiles without your personal GitHub account being logged in on it.
- **GPG / signing key**: proves who wrote a commit (GitHub shows it as *Verified*). It grants no access, and this setup doesn't use one.

When you stop using a Mac, delete its keys on those pages.

Two accounts on the same service on one Mac, e.g. personal and work GitHub: give the second one its own name, and use that name in its clone URLs:

```sh
ssh-key github.com github-work
git clone git@github-work:company/repo.git
```

## 3. App permissions and licenses

Open each app once and grant what it asks for:

- **LinearMouse**: Accessibility permission
- **Rectangle**: Accessibility permission. Turn off macOS's own window tiling. Turn off *Animate footprint*, turn on *Haptic feedback*.
- **Hidden Bar**: permissions, *Start at Login*, *Autocollapse: 30s*, don't show the menu.
  If macOS says it's damaged, run: `sudo xattr -dr com.apple.quarantine "/Applications/Hidden Bar.app"`
- **Karabiner-Elements**: permissions (its config is already in `~/.config/karabiner`)
- **Stats**: import settings from the file `~/.config/Stats.plist`
- **Rocket**: permissions, enter the license. *Start at Login*, *Fuzzy search*, *Double key trigger*, *Size: Large*.
- **Vivid**: permissions, enter the license
- **VS Code**: sign in to Settings Sync with GitHub and let it pull your settings

## 4. System Settings (manual)

The script can't set these:

- **General → AirDrop & Handoff**: allow Handoff
- **Desktop & Dock**: Dock size ⅓, magnification ½
- **Control Center**: hide Spotlight from the menu bar
- **Displays**: *More Space*; Night Shift from sunset to sunrise
- **Keyboard → Text Input**: add your native language
- **Trackpad**: tracking speed 6/10, click *Light*
- **Internet Accounts**: add personal and work Mail and Calendar accounts
- **Wallet & Apple Pay**: add cards
- **Messages**: turn on *Messages in iCloud*
- **Finder**: set up the Favourites sidebar

## What `setup.sh` sets

You don't need to do these by hand:

- **Dock**: auto-hide, *Scale effect*, minimise into the app icon
- **Mission Control**: don't rearrange Spaces automatically
- **Hot corner**: bottom right starts the screensaver
- **Finder**: path bar and status bar
- **Appearance**: scroll bars only while scrolling
- **Keyboard**: fastest key repeat, shortest delay before repeat
- **Typing**: no autocorrect, auto-capitalisation, double-space full stop or smart quotes and dashes
- **Menu bar**: tighter icon spacing, so fewer icons hide under the notch

## Keeping the dotfiles up to date

On a Mac that's already set up:

```sh
cd ~/.config
# Apps installed here but missing from both Brewfiles (lists only, removes nothing)
cat Brewfile Brewfile.develop | brew bundle cleanup --file=-
# Add the ones you want to Brewfile (every Mac) or Brewfile.develop (as needed), then:
git diff
git add -u && git commit -m "update" && git push
```

`git add -u` only stages files that are already tracked. Apps keep caches and logins in `~/.config` too, so add a new file with `git add <path>` only once you've checked it's config, not state or secrets.

On the other Macs, run `~/.config/setup.sh` again to pull the changes and install anything new.

Shell config for one Mac only, like work aliases, goes in `~/.config/zsh/.zshrc.local`, which git ignores.

## What's where

| Path | What it is |
|---|---|
| `setup.sh` | sets up a Mac (see above) |
| `bin/ssh-key` | logs a Mac in to a git host with an SSH key |
| `bin/imgls` | iTerm2's `imgls` with 20x10 thumbnails, names centred on images, and the right highlighting for env files |
| `Brewfile`, `Brewfile.develop` | apps and CLIs: every Mac, and as needed |
| `zsh/` | shell config. `.zshrc` holds aliases, completion, plugins, `klaude` and `airpods` |
| `git/config`, `git/ignore` | global git settings and ignore rules |
| `iterm2/` | iTerm2 settings (profile *calm*); shell integration loads from the app itself |
| `karabiner/`, `linearmouse/`, `Stats.plist` | keyboard, mouse and menu bar app settings |
| `useful-commands` | one-off commands worth remembering |
