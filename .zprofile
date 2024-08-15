# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"

# allow new pnpm versions 
export COREPACK_ENABLE_STRICT=0

# my aliases
alias p=pnpm
alias py=python3

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
