# Always run as native ARM64 (prevents Rosetta 2 shell sessions)
[[ "$(uname -m)" != "arm64" ]] && exec arch -arm64 "$SHELL" "$@"

# p10k
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# completions
# generate docker completion file on first run (replaces oh-my-zsh docker plugin)
if command -v docker &>/dev/null; then
  mkdir -p "$HOME/.docker/completions"
  [[ -f "$HOME/.docker/completions/_docker" ]] || docker completion zsh > "$HOME/.docker/completions/_docker"
fi
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit && compinit
autoload -Uz colors && colors
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# colored man pages via bat (replaces oh-my-zsh colored-man-pages plugin)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# homebrew plugins
# source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# to customize, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh 

eval "$(zoxide init zsh)"
source <(fzf --zsh)
# avoid recursive startship loading
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

# zsh options
setopt AUTO_CD

# set vi mode
bindkey -v
function vi-yank-pbcopy() { zle vi-yank; echo -n "$CUTBUFFER" | pbcopy }
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# aliases — loaded after all formula tools are initialized above
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export LOCAL_BIN="$HOME/.local/bin"
export PATH="$LOCAL_BIN:$PATH"
