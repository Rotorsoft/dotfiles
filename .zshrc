# Load Powerlevel10k prompt configuration (interactive)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

plugins=(git docker docker-compose colored-man-pages colorize)

# Oh My Zsh configuration (interactive)
export ZSH="${HOME}/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Enable Zsh completions (interactive)
autoload -Uz compinit && compinit

# Homebrew plugins (syntax highlighting, autosuggestions, Powerlevel10k theme)
source $HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Prompt customization file (interactive)
# to customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh 

# nvm
[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" 
nvm use default 

# Bun completions
[ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"

# Aliases (interactive)
alias la='lsd -la'
alias g=git
alias p=pnpm
alias python=python3
alias py=python3
alias pip=pip3
