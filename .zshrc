# Always run as native ARM64 (prevents Rosetta 2 shell sessions)
[[ "$(uname -m)" != "arm64" ]] && exec arch -arm64 "$SHELL" "$@"

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
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"
source <(fzf --zsh)
# avoid recursive startship loading
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

# history (replaces oh-my-zsh lib/history.zsh defaults)
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # timestamps in $HISTFILE
setopt hist_expire_dups_first # drop dupes first when trimming
setopt hist_ignore_dups       # don't record consecutive dupes
setopt hist_ignore_space      # leading space hides command from history
setopt hist_verify            # confirm `!!`/`!$` expansions before running
setopt share_history          # sync history across live shells

# directory navigation (replaces oh-my-zsh lib/directories.zsh)
setopt auto_cd                # `foo` → `cd foo` if foo is a dir
setopt auto_pushd             # every cd pushes to the dir stack
setopt pushd_ignore_dups      # no dupes in the dir stack
setopt pushdminus             # `cd -2` instead of `cd +2`

# set vi mode
bindkey -v
function vi-yank-pbcopy() { zle vi-yank; echo -n "$CUTBUFFER" | pbcopy }
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

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

export EDITOR="nvim"
export VISUAL="nvim"

# Machine-specific overrides (paths to tools that only live on some
# hosts, work identities, secrets). Kept outside the dotfiles repo.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
