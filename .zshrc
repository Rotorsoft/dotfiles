# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(git docker docker-compose colored-man-pages colorize)

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# zsh completions
autoload -Uz compinit && compinit
autoload -Uz colors && colors

# homebrew plugins (syntax highlighting, autosuggestions, p10k theme)
source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# to customize, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh 

# aliases
alias la='lsd -la'
alias g=git
alias use=use_tool
