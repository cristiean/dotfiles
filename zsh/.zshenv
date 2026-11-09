# Loaded by every zsh (login, interactive, scripts). Keep it to env vars.

typeset -U path   # drop duplicate PATH entries

# Dotfiles commands (ssh-key, ...) and user-installed CLIs (uv, pipx, ...)
export PATH="$HOME/.config/bin:$HOME/.local/bin:$PATH"

# Homebrew: install and upgrade without asking "proceed?" first (same as -y)
export HOMEBREW_NO_ASK=1
