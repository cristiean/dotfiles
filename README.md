# dotfiles

My macOS setup: shell, git, terminal, apps and system settings. It lives in `~/.config`, and one script sets up a new Mac from it.

## Set up a new Mac

### 1. Run the setup script

On the new Mac, open Terminal and run this command. It needs no GitHub login:

```sh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/cristiean/dotfiles/master/setup.sh)"
```

The script does the following:

- Installs Homebrew and, with it, the Xcode Command Line Tools, which provide git.
- Clones the dotfiles to `~/.config` and writes `~/.zshenv`, so that zsh loads its config from `~/.config/zsh`.
- Makes commits to the dotfiles use your personal name and email, even on a work Mac.
- Shows a list of apps and CLIs, and installs the entries that you leave checked.
- Points iTerm2 at `~/.config/iterm2` for its settings.
- Builds BluetoothBar from `menubar/` and starts it. Allow Bluetooth when macOS asks.
- Links the [agent skills](#agent-skills) in `~/.config/skills` into Claude Code and Codex.
- Applies the macOS settings listed under [What `setup.sh` sets](#what-setupsh-sets).

In the list of apps and CLIs, the entries of `Brewfile` start checked. The entries of `Brewfile.develop` start unchecked: they are dev and work tools, such as Kubernetes, AWS, OrbStack, DBeaver and Claude Code. Move with the arrow keys, press Space to check or uncheck an entry, and press Enter to install the checked entries. The list shows the other keys at the top.

The script saves the choice in `~/.config/Brewfile.local`, which git ignores, and the next run starts from that choice. To change the choice later, run `~/.config/setup.sh` again.

The script is safe to run again, because every step checks before it acts.

When the script finishes, log out and log back in. Then open iTerm2.

### 2. Log in to git

Git logs in to a service with an SSH key, and each Mac has one key for each service. The `ssh-key` command creates the key and copies its public key to the clipboard. For GitHub and for any GitLab, it also prints the exact page to paste the key into and a command to test the key.

When `ssh-key` asks for a passphrase, set one. The Keychain remembers it. You can paste the public key from any device, because a public key isn't secret.

[Which key does what](#which-key-does-what) explains what each kind of key can reach.

#### On a personal Mac

Use one key for your whole GitHub account. Every repo then works, the dotfiles included.

Create the key and paste it into the SSH keys page of your GitHub account:

```sh
ssh-key github.com
```

Then make the dotfiles push with that key:

```sh
git -C ~/.config remote set-url --push origin git@github.com:cristiean/dotfiles.git
```

Other repos need only an SSH clone URL, such as `git@github.com:owner/repo.git`.

#### On a work Mac

Keep your personal GitHub account off a work Mac. Create a key for the company's git host, `gitlab.company.com` in this example, and paste it into your work account there:

```sh
ssh-key gitlab.company.com
```

If the company uses GitHub, run `ssh-key github.com` and paste the key into your *work* GitHub account.

To let the work Mac push the dotfiles, and nothing else, run:

```sh
~/.config/setup.sh --push-access
```

The command asks you to paste a key into the Deploy keys page of the dotfiles repo and to select **Allow write access**.

Then set your work email for work repos. The dotfiles keep your personal email either way:

```sh
git config --file ~/.gitconfig user.email "you@company.com"
```

#### Two accounts on one service

One Mac can use two accounts on the same service, for example a personal and a work GitHub account. Give the second account its own name, and use that name in its clone URLs:

```sh
ssh-key github.com github-work
git clone git@github-work:company/repo.git
```

### 3. Set up the apps

Open each app once and do what this list says:

- LinearMouse: grant the Accessibility permission.
- Rectangle: grant the Accessibility permission, and turn off the window tiling of macOS itself. In Rectangle, turn off **Animate footprint** and turn on **Haptic feedback**.
- Karabiner-Elements: grant the permissions that it asks for. Its config is already in `~/.config/karabiner`.
- Stats: import the settings from the file `~/.config/Stats.plist`.
- Rocket: grant the permissions that it asks for and enter the license. Turn on **Start at Login**, **Fuzzy search** and **Double key trigger**, and set **Size** to **Large**.
- Vivid: grant the permissions that it asks for and enter the license.
- VS Code: sign in to Settings Sync with GitHub and let it pull your settings. Its SQL formatter runs the `sqlfluff` command, so check `sqlfluff` in the list of apps on a Mac where you format SQL.

### 4. Change System Settings by hand

The script can't set these:

| Where | What to set |
|---|---|
| General > AirDrop & Handoff | Allow Handoff |
| Desktop & Dock | Dock size ⅓, magnification ½ |
| Control Center | Hide Spotlight from the menu bar |
| Displays | **More Space**, and Night Shift from sunset to sunrise |
| Keyboard > Text Input | Add your native language |
| Trackpad | Tracking speed 6/10, click **Light** |
| Internet Accounts | Add the personal and work Mail and Calendar accounts |
| Wallet & Apple Pay | Add cards |
| Messages | Turn on **Messages in iCloud** |
| Finder | Set up the Favourites sidebar |

[What `setup.sh` sets](#what-setupsh-sets) lists the settings that the script applies for you.

## Keep the dotfiles up to date

On a Mac that is already set up, save its changes to the dotfiles in three steps:

1. List the apps that are installed on this Mac and missing from both Brewfiles. The command only lists them and removes nothing:

   ```sh
   cd ~/.config
   cat Brewfile Brewfile.develop | brew bundle cleanup --file=-
   ```

2. Add the apps that you want to `Brewfile`, whose entries start checked in the list of apps, or to `Brewfile.develop`, whose entries start unchecked.

3. Review the changes. Then commit and push them:

   ```sh
   git diff
   git add -u && git commit -m "update" && git push
   ```

`git add -u` stages only the files that git already tracks. Apps keep caches and logins in `~/.config` too. Before you add a new file with `git add <path>`, check that it holds config, and not state or secrets.

On the other Macs, run `~/.config/setup.sh` again. It pulls the changes and shows the list of apps, where a new entry of `Brewfile` starts checked. The pull keeps the uncommitted changes on that Mac. If a file changed both on that Mac and in the dotfiles, the script names the file and skips the pull.

Shell config for one Mac only, such as work aliases, goes in `~/.config/zsh/.zshrc.local`, which git ignores.

## Agent skills

A skill is a folder of instructions that a coding agent loads when a task calls for it. Each folder in `skills/` is one skill. `setup.sh` links each skill into three places, so that every agent reads the same copy:

| Agent | Linked into | Call it by name with |
|---|---|---|
| Claude Code, work account (`claude`) | `~/.claude/skills/` | `/technical-writing` |
| Claude Code, personal account (`klaude`) | `~/.claude-personal/skills/` | `/technical-writing` |
| Codex | `~/.agents/skills/` | `$technical-writing` |

An agent also loads a skill by itself when a task matches the description of the skill.

The skill in `skills/technical-writing/` makes an agent write and edit documentation, messages and error text so that they read clearly on the first pass. `SKILL.md` holds the rules, `references/` holds the detail and `SOURCES.md` records where each rule comes from.

### Install the skills

`setup.sh` installs the skills when it sets up a Mac. To install or refresh only the skills, run:

```sh
~/.config/setup.sh --skills
```

The command is safe to run again. Check the links:

```sh
ls -l ~/.claude/skills ~/.claude-personal/skills ~/.agents/skills
```

Then start a new session in the agent, because a session that is already open doesn't see a new skill. In Claude Code, type `/` and look for `technical-writing`. In Codex, type `$` or run `/skills`.

Other agents need a different install:

- Claude desktop or web chat, Cowork and cloud sessions don't read these folders. Upload the skill folder as a zip file in the skills settings of the app, and upload it again after each change.
- For any other agent that supports skills, link `~/.config/skills/technical-writing` into the personal skills folder of that agent.
- For an agent without skills, tell the agent to read `~/.config/skills/technical-writing/SKILL.md` before it writes.

### Change or add a skill

To change a skill, edit its files. Because each agent reads the skill through a link, every agent sees the change in its next session. To add a skill, create `skills/<name>/SKILL.md` and run `~/.config/setup.sh --skills`.

The test prompts for a skill are in its `evals/` folder. A test run writes its outputs to `skills/<name>-workspace/`, which git ignores.

## Reference

### What `setup.sh` sets

The setup script applies these macOS settings, so you don't need to set them by hand:

| Area | Setting |
|---|---|
| Dock | Auto-hide, **Scale effect**, minimise into the app icon |
| Mission Control | Spaces keep a fixed order |
| Hot corner | Bottom right starts the screensaver |
| Finder | Path bar and status bar |
| Appearance | Scroll bars only while scrolling |
| Keyboard | Fastest key repeat, shortest delay before repeat |
| Typing | No autocorrect, auto-capitalisation, double-space full stop, smart quotes or smart dashes |
| Menu bar | Tighter icon spacing, so fewer icons hide under the notch |

### Which key does what

- An account key, which `ssh-key` creates, lets git act as you on that service. It has access to every repo that your account can reach.
- A deploy key, which `setup.sh --push-access` creates, is attached to the dotfiles repo and not to an account. It can push to the dotfiles and to nothing else. That is why a work Mac can push the dotfiles without your personal GitHub account being logged in on it.
- A GPG key, or signing key, proves who wrote a commit. GitHub shows such a commit as **Verified**. A signing key grants no access, and this setup doesn't use one.

When you stop using a Mac, delete its keys on the pages where you pasted them.

### Keys for editing a command

The command line takes the same editing keys as a macOS text field. `zsh/.zshrc` and the iTerm2 profile set them up.

| Keys | What they do |
|---|---|
| Cmd+← and Cmd+→ | Jump to the start or the end of the line |
| Option+← and Option+→ | Jump one word back or forward |
| Cmd+Delete | Delete the line |
| Option+Delete | Delete the word before the cursor |
| Shift with any of the arrow keys above | Select. The selection is copied to the clipboard. |
| Any character, or a paste | Replace the selection |
| Delete | Remove the selection |
| Cmd+X | Cut the selection |

Terminal.app keeps the Cmd keys for itself. In Terminal.app, use Ctrl+A for the start of the line, Ctrl+E for the end of the line and Ctrl+U to delete the line. The Option and Shift keys work the same.

### What's where

| Path | What it is |
|---|---|
| `setup.sh` | Sets up a Mac. See [Set up a new Mac](#set-up-a-new-mac). |
| `Brewfile`, `Brewfile.develop` | Apps and CLIs for the list in `setup.sh`. The entries of `Brewfile` start checked, and the entries of `Brewfile.develop` start unchecked. |
| `bin/ssh-key` | Logs a Mac in to a git host with an SSH key |
| `bin/imgls` | iTerm2's `imgls` with 20x10 thumbnails, names centred on images, and the right highlighting for env files |
| `zsh/` | Shell config. `.zshrc` holds aliases, completion, plugins, `klaude`, `airpods` and `repo`, which opens the repo page at this branch and folder. |
| `git/config`, `git/ignore` | Global git settings and ignore rules |
| `sqlfluff/.sqlfluff` | SQLFluff settings for every project: the SQL dialect to use when a project sets none |
| `iterm2/` | iTerm2 settings, with the profile `calm`. Shell integration loads from the app itself. |
| `karabiner/`, `linearmouse/`, `Stats.plist` | Keyboard, mouse and menu bar app settings |
| `menubar/` | BluetoothBar: menu bar icons for the AirPods and the keyboard. A right-click toggles the device: it connects or disconnects the AirPods, and pairs or unpairs the keyboard. A left-click shows a menu. The logic is in `zsh/bluetooth.zsh`. |
| `skills/` | [Agent skills](#agent-skills) for Claude Code and Codex |
| `useful-commands` | One-off commands worth remembering |
