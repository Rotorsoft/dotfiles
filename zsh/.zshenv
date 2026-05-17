# Runs for EVERY zsh invocation, including scripts and non-interactive
# shells. Keep this minimal — only env vars that must be set everywhere
# (editor for git/cron, XDG locations, GPG TTY, personal bin in PATH).

# XDG base directories — many tools (bat, zoxide, fd, ripgrep, neovim, ...)
# relocate their state when these are set.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor — must be set for non-interactive contexts (git commit from IDE,
# crontab -e, ssh host cmd, etc.), not just interactive shells.
export EDITOR="nvim"
export VISUAL="nvim"

# Colored man pages via bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# GPG (commit signing needs to know which TTY to prompt on)
export GPG_TTY=$(tty)

# Personal bin — also needs to be available to non-interactive shells.
export PATH="$HOME/.local/bin:$PATH"
