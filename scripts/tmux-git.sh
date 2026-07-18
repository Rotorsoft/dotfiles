#!/usr/bin/env sh
# Mirror starship's git_branch + git_status segment for use in tmux status-right.
# tmux #() renders #[...] style directives but not raw ANSI, so we run the same
# starship modules (same starship.toml) and translate their SGR codes to tmux.
#
# Usage: tmux-git.sh <path>   (called from .tmux.conf with #{pane_current_path})

path="${1:-$PWD}"

# Outside a git work tree: print nothing.
git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

export STARSHIP_CONFIG="$HOME/.dotfiles/starship.toml"
out="$(starship module git_branch --path "$path" 2>/dev/null)$(starship module git_status --path "$path" 2>/dev/null)"

printf '%s' "$out" | perl -pe '
  s/\e\[30m/#[fg=black]/g;
  s/\e\[31m/#[fg=red]/g;
  s/\e\[32m/#[fg=green]/g;
  s/\e\[33m/#[fg=yellow]/g;
  s/\e\[34m/#[fg=blue]/g;
  s/\e\[35m/#[fg=magenta]/g;
  s/\e\[36m/#[fg=cyan]/g;
  s/\e\[37m/#[fg=white]/g;
  s/\e\[1m/#[bold]/g;
  s/\e\[0m/#[nobold]#[fg=default]/g;
  s/\e\[[0-9;]*m//g;      # strip any remaining SGR codes
'
