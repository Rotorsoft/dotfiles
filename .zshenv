# Bootstrap stub — zsh always reads $HOME/.zshenv first, before it knows
# about $ZDOTDIR. Point it at the real config dir, then source the real
# .zshenv from there.
export ZDOTDIR="$HOME/.config/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
