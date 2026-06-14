# Always run as native ARM64 (prevents Rosetta 2 shell sessions).
# Kept here rather than in .zshenv so scripts/non-interactive shells aren't
# affected — only interactive sessions force the re-exec.
[[ "$(uname -m)" != "arm64" ]] && exec arch -arm64 "$SHELL" "$@"

# ── completions ────────────────────────────────────────────────────────────────
# generate docker completion file on first run (replaces oh-my-zsh docker plugin).
# Honors $DOCKER_CONFIG (set in .zshenv to $XDG_CONFIG_HOME/docker), falling back
# to ~/.docker on hosts that don't have it set.
if command -v docker &>/dev/null; then
  mkdir -p "${DOCKER_CONFIG:-$HOME/.docker}/completions"
  [[ -f "${DOCKER_CONFIG:-$HOME/.docker}/completions/_docker" ]] || \
    docker completion zsh > "${DOCKER_CONFIG:-$HOME/.docker}/completions/_docker"
fi
# Prepend our own completions dir so it shadows Homebrew's site-functions
# where needed (e.g. our colon-safe _pnpm).
fpath=($ZDOTDIR/completions "${DOCKER_CONFIG:-$HOME/.docker}/completions" $fpath)

# Cache compinit's dump under XDG_CACHE_HOME instead of $HOME/.zcompdump.
mkdir -p "$XDG_CACHE_HOME/zsh"
# Surface insecure fpath entries (so we know about them), then -i so compinit
# silently skips them instead of blocking the shell with a y/n prompt.
autoload -Uz compinit compaudit
() {
  local -a insecure=( ${(f)"$(compaudit 2>/dev/null)"} )
  (( ${#insecure} )) || return
  print -u2 "zsh: ignoring insecure fpath entries:"
  printf '  %s\n' "${insecure[@]}" >&2
}
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump"
autoload -Uz colors && colors

# case-insensitive + partial-word completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# arrow-key menu instead of multi-column dump
zstyle ':completion:*' menu select

# ── plugins ────────────────────────────────────────────────────────────────────
# Order matters: fzf-tab must come after compinit and before fast-syntax-highlighting.
# zsh-autosuggestions before highlighting. Highlighting last.
# fzf-tab has no brew formula — installed via git clone in scripts/install.sh.
[[ -f "$XDG_DATA_HOME/zsh/fzf-tab/fzf-tab.plugin.zsh" ]] && source "$XDG_DATA_HOME/zsh/fzf-tab/fzf-tab.plugin.zsh"
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# fzf-tab: use fzf instead of zsh's default tab menu, with previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=plain --line-range=:200 $realpath 2>/dev/null || eza -1 --color=always --icons=auto $realpath 2>/dev/null'
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border=rounded

# ── fzf ────────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --preview-window=right:60%:wrap:border-left
'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain,numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza -1 --color=always --icons=auto {}'"
source <(fzf --zsh)
# Rebind the fzf file picker from default ctrl-t to ctrl-f.
bindkey -r '^t'
bindkey '^f' fzf-file-widget

# Tab: accept the inline autosuggestion if one is shown, else fall through
# to fzf-tab's completion menu. `source <(fzf --zsh)` above rebinds ^I to
# fzf-completion; this restores fzf-tab and layers autosuggest-accept on top.
_tab-accept-or-fzf-tab() {
  if [[ -n $POSTDISPLAY ]]; then
    zle autosuggest-accept
  else
    zle fzf-tab-complete
  fi
}
zle -N _tab-accept-or-fzf-tab

# ── version manager (replaces nvm; reads .nvmrc / .tool-versions / .mise.toml) ─
eval "$(mise activate zsh)"

# ── shell history (atuin: sqlite-backed fuzzy search, bound to ctrl-h) ─────────
# Disable atuin's default bindings; up-arrow stays on prefix search (below),
# ctrl-h replaces the default ctrl-r.
# NOTE: ctrl-h conflicts with Backspace on terminals that send ^H instead of ^?.
# Ghostty defaults to ^? so this is fine; check your terminal if Backspace breaks.
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"
bindkey '^h' atuin-search

# ── zoxide & starship ──────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"
# avoid recursive starship loading
if [[ "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select" || \
      "${widgets[zle-keymap-select]#user:}" == "starship_zle-keymap-select-wrapped" ]]; then
    zle -N zle-keymap-select "";
fi
eval "$(starship init zsh)"

# ── history ────────────────────────────────────────────────────────────────────
HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # timestamps in $HISTFILE
setopt hist_expire_dups_first # drop dupes first when trimming
setopt hist_ignore_dups       # don't record consecutive dupes
setopt hist_ignore_space      # leading space hides command from history
setopt hist_verify            # confirm `!!`/`!$` expansions before running
setopt share_history          # sync history across live shells

# ── directory navigation ───────────────────────────────────────────────────────
setopt auto_cd                # `foo` → `cd foo` if foo is a dir
setopt auto_pushd             # every cd pushes to the dir stack
setopt pushd_ignore_dups      # no dupes in the dir stack
setopt pushdminus             # `cd -2` instead of `cd +2`
setopt numeric_glob_sort      # file9 before file10, not file1

# ── vi mode ────────────────────────────────────────────────────────────────────
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

# Bind Tab after vi mode is active so it lands in the right keymap.
# Widget is defined above, right after fzf init.
bindkey -M viins '^I' _tab-accept-or-fzf-tab
bindkey -M emacs '^I' _tab-accept-or-fzf-tab

# ── aliases ────────────────────────────────────────────────────────────────────
[[ -f "$ZDOTDIR/.aliases" ]] && source "$ZDOTDIR/.aliases"

# ── pnpm ───────────────────────────────────────────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── machine-specific overrides ─────────────────────────────────────────────────
# Paths to tools that only live on some hosts, work identities, secrets.
# Kept outside the dotfiles repo.
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
