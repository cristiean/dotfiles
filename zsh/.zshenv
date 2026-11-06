# Loaded by every zsh (login, interactive, scripts). Keep it to env vars.

typeset -U path   # drop duplicate PATH entries

# User-installed CLIs (uv, pipx, Claude Code, ...)
export PATH="$HOME/.local/bin:$PATH"
