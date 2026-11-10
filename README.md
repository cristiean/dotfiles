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
- Links the [agent skills](#agent-skills) in `~/.config/skills` into Claude Code and Codex
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

## Editing a command

Like in a macOS text field (set up in `zsh/.zshrc` and the iTerm2 profile):

| Keys | Does |
|---|---|
| Cmd+←/→, Opt+←/→ | jump to line start/end, word back/forward |
| Cmd+Delete, Opt+Delete | delete the line, the word before the cursor |
| Shift + any of those arrows | select; the selection is copied to the clipboard |
| type / paste / Delete / Cmd+X | replace / replace / remove / cut the selection |

Terminal.app keeps Cmd keys for itself, so there use Ctrl+A, Ctrl+E and Ctrl+U for line start, line end and delete line. The Option and Shift keys work the same.

## Agent skills

A skill is a folder of instructions that a coding agent loads when a task calls for it. Each folder in `skills/` is one skill, and `setup.sh` links it into three places, so every agent reads the same copy:

| Agent | Linked into | Call it by name with |
|---|---|---|
| Claude Code, work account (`claude`) | `~/.claude/skills/` | `/technical-writing` |
| Claude Code, personal account (`klaude`) | `~/.claude-personal/skills/` | `/technical-writing` |
| Codex | `~/.agents/skills/` | `$technical-writing` |

The agents also pick a skill up by themselves when a task matches its description.

`skills/technical-writing/` makes an agent write and edit documentation, messages and error text so they read clearly on the first pass. `SKILL.md` holds the rules, `references/` the detail and `SOURCES.md` where each rule comes from.

### Install

`setup.sh` installs the skills as part of setting up a Mac. To install or refresh only the skills:

```sh
~/.config/setup.sh --skills
```

It's safe to run again. Check the links, then start a new session in the agent; a session that's already open doesn't see a new skill:

```sh
ls -l ~/.claude/skills ~/.claude-personal/skills ~/.agents/skills
```

In Claude Code, type `/` and look for `technical-writing`. In Codex, type `$` or run `/skills`.

Other agents:

- **Claude desktop or web chat, Cowork and cloud sessions** don't read these folders. Upload the skill folder as a zip file in the app's skills settings, and upload it again after each change.
- **Any other agent that supports skills**: link `~/.config/skills/technical-writing` into that agent's personal skills folder.
- **An agent without skills**: tell it to read `~/.config/skills/technical-writing/SKILL.md` before it writes.

### Change or add a skill

To change a skill, edit its files; the links mean every agent sees the change in its next session. To add one, create `skills/<name>/SKILL.md` and run `~/.config/setup.sh --skills`.

Test prompts for a skill live in its `evals/` folder. The outputs of a test run go to `skills/<name>-workspace/`, which git ignores.

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
| `menubar/` | BluetoothBar: menu bar icons for the AirPods and keyboard. Right-click toggles: AirPods connect/disconnect, keyboard pair/unpair; left-click shows a menu (logic in `zsh/bluetooth.zsh`) |
| `bin/imgls` | iTerm2's `imgls` with 20x10 thumbnails, names centred on images, and the right highlighting for env files |
| `Brewfile`, `Brewfile.develop` | apps and CLIs: every Mac, and as needed |
| `zsh/` | shell config. `.zshrc` holds aliases, completion, plugins, `klaude`, `airpods` and `repo` (open the repo page at this branch and folder) |
| `git/config`, `git/ignore` | global git settings and ignore rules |
| `skills/` | [agent skills](#agent-skills) for Claude Code and Codex |
| `iterm2/` | iTerm2 settings (profile *calm*); shell integration loads from the app itself |
| `karabiner/`, `linearmouse/`, `Stats.plist` | keyboard, mouse and menu bar app settings |
| `useful-commands` | one-off commands worth remembering |
