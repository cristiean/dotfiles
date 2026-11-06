# Homebrew: PATH, MANPATH, HOMEBREW_PREFIX (Apple silicon, then Intel)
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $_brew ]] && { eval "$($_brew shellenv)"; break }
done
unset _brew

# OrbStack: command-line tools and integration (no-op if not installed).
# OrbStack won't add this line again if it's removed.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
