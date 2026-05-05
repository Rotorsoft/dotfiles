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

# docker-compose completions (replaces oh-my-zsh docker-compose plugin)
[[ -f /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion ]] && \
  source /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion

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

# set vi mode
bindkey -v

# aliases
alias b=brew
alias c=container
alias g=git
alias p=pnpm
alias v=nvim
alias y=yazi
alias py=python3
alias pip=pip3
alias use=use_tool
alias bup='brew update && brew upgrade' 
alias buc='brew cleanup && brew doctor'
alias ls='eza -la --icons=auto --sort=name'
alias lt='eza -la --icons=auto --sort=time'
alias ld='eza -laD --icons=auto --sort=name'
alias lf='eza -laf --icons=auto --sort=size'
alias lg='eza -laf --icons=auto --git --sort=size'
alias la='eza -laT -L3 --icons=auto'
alias gll='git log --graph --decorate --abbrev-commit --date=format:"%m-%d" --pretty=format:"%C(auto)%h %Cgreen%>(5)%ad%Creset %Cblue%<(7,trunc)%an%Creset %C(auto)%d %<(50,trunc)%s" --branches'

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export LOCAL_BIN="$HOME/.local/bin"
export PATH="$LOCAL_BIN:$PATH"
