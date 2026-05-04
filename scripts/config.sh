#!/usr/bin/env bash
set -euo pipefail

# Symlink dotfiles into the right places. Idempotent and safe to re-run.
# - Atomically replaces existing symlinks (ln -sfn)
# - Backs up real files/directories that would be overwritten
# - Creates parent directories as needed
# - Skips links whose source is missing (e.g. optional configs)
# - Prunes stale symlinks that used to point into $DOTFILES_DIR

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Error: $DOTFILES_DIR does not exist" >&2
  exit 1
fi

link() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "  skip (source missing): $src"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  # If dst is a regular file or real directory (not a symlink), back it up
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.backup-$(date +%Y%m%d%H%M%S)"
    echo "  backup:  $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -sfn "$src" "$dst"
  echo "  link:    $dst -> $src"
}

echo "==> Linking dotfiles from $DOTFILES_DIR"

# $HOME
link "$DOTFILES_DIR/.gitconfig"  "$HOME/.gitconfig"
link "$DOTFILES_DIR/.zprofile"   "$HOME/.zprofile"
link "$DOTFILES_DIR/.zshrc"      "$HOME/.zshrc"
link "$DOTFILES_DIR/.tmux.conf"  "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/keychron_q6_max_ansi_knob.layout.json" \
     "$HOME/keychron_q6_max_ansi_knob.layout.json"

# ~/.config
link "$DOTFILES_DIR/starship.toml"          "$HOME/.config/starship.toml"
link "$DOTFILES_DIR/nvim"                   "$HOME/.config/nvim"
link "$DOTFILES_DIR/yazi/yazi.toml"         "$HOME/.config/yazi/yazi.toml"
link "$DOTFILES_DIR/yazi/themes/grapevine"  "$HOME/.config/yazi/theme.toml"
link "$DOTFILES_DIR/ghostty/config"         "$HOME/.config/ghostty/config"
link "$DOTFILES_DIR/ghostty/themes"         "$HOME/.config/ghostty/themes"

# VS Code
link "$DOTFILES_DIR/vscode/settings.json" \
     "$HOME/Library/Application Support/Code/User/settings.json"
link "$DOTFILES_DIR/vscode/icons" \
     "$HOME/.vscode/extensions/icons"

# Make scripts executable
chmod +x "$DOTFILES_DIR"/scripts/*.sh

# Prune stale symlinks that used to point into $DOTFILES_DIR but no longer resolve.
# Scoped to known locations only — never touches unrelated symlinks.
prune_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -maxdepth 1 -type l 2>/dev/null | while read -r ln; do
    local target
    target=$(readlink "$ln")
    if [[ "$target" == "$DOTFILES_DIR"/* ]] && [[ ! -e "$target" ]]; then
      echo "  prune:   $ln -> $target (target gone)"
      rm -f "$ln"
    fi
  done
}

echo "==> Pruning stale dotfile symlinks"
prune_dir "$HOME"
prune_dir "$HOME/.config"
prune_dir "$HOME/.config/yazi"
prune_dir "$HOME/.config/ghostty"

echo "==> Done"
