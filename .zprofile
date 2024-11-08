# homebrew bin
export HOMEBREW_PREFIX="/opt/homebrew"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# nvm dir
export NVM_DIR="${HOME}/.nvm"

# psql path
export PATH="${HOMEBREW_PREFIX}/opt/libpq/bin:$PATH"

# java path
export PATH="${HOMEBREW_PREFIX}/opt/openjdk/bin:$PATH"

# python3 path
export PATH="${HOMEBREW_PREFIX}/bin/python3:$PATH"

# modular paths
export MODULAR_HOME="${HOMEBREW_PREFIX}/bin/.modular"
export PATH="${MODULAR_HOME}/pkg/packages.modular.com_mojo/bin:$PATH"

# pnpm path
export PNPM_HOME="${HOME}/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Corepack settings for pnpm
export COREPACK_ENABLE_STRICT=0 # to allo new pnpm versions

# gcloud path
#source ${HOME}/google-cloud-sdk/path.zsh.inc 
#source ${HOME}/google-cloud-sdk/completion.zsh.inc

# Initialize Homebrew environment
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# Initialize zoxide
eval "$(zoxide init zsh)"
