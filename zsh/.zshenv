# Runs for EVERY zsh invocation, including scripts and non-interactive
# shells. Keep this minimal — only env vars that must be set everywhere
# (editor for git/cron, XDG locations, GPG TTY, personal bin in PATH).

# XDG base directories — many tools (bat, zoxide, fd, ripgrep, neovim, ...)
# relocate their state when these are set.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Tools that DON'T autodetect XDG but accept a custom path via env var.
# Setting these here means a fresh machine never accumulates a ~/.foo for
# any of these — they create their state under XDG_* from day one.
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"   # Python 3.13+
export PSQL_HISTORY="$XDG_STATE_HOME/psql/history"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export MPLCONFIGDIR="$XDG_CACHE_HOME/matplotlib"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle/config"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGet"

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
