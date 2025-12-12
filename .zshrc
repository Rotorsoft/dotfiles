# p10k
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

export ZSH="$HOME/.oh-my-zsh"
plugins=(git docker docker-compose colored-man-pages colorize)
source $ZSH/oh-my-zsh.sh

# completions
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit && compinit
autoload -Uz colors && colors

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
alias ls='eza -la --icons=auto --sort=name'
alias lt='eza -la --icons=auto --sort=time'
alias ld='eza -laD --icons=auto --sort=name'
alias lf='eza -laf --icons=auto --git --sort=size'
alias la='eza -laT -L2 --git-ignore --icons=auto'
alias c=container
alias g=git
alias p=pnpm
alias v=nvim
alias y=yazi
alias py=python3
alias pip=pip3
alias use=use_tool
alias gll='git log --graph --decorate --abbrev-commit --date=format:"%m-%d" --pretty=format:"%C(auto)%h %Cgreen%>(5)%ad%Creset %Cblue%<(7,trunc)%an%Creset %C(auto)%d %<(50,trunc)%s" --branches'
