#!/usr/bin/env bash
set -euo pipefail

# Compare installed brew state against tracked Brewfiles.
# Auto-discovers Brewfile + Brewfile.* in DOTFILES_DIR.
#
# Usage:
#   update-brewfiles.sh           # interactive: prompt to route each new entry
#   update-brewfiles.sh --check   # read-only: report drift, exit non-zero if any

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CHECK_ONLY="no"

case "${1:-}" in
  --check) CHECK_ONLY="yes" ;;
  -h|--help) sed -n '3,8p' "$0"; exit 0 ;;
  "") ;;
  *) echo "Unknown flag: $1" >&2; exit 1 ;;
esac

# Build the list of Brewfiles: essentials first, then Brewfile.* alphabetically.
shopt -s nullglob
BUNDLES=("${DOTFILES_DIR}/Brewfile")
for f in "${DOTFILES_DIR}"/Brewfile.*; do
  BUNDLES+=("$f")
done

if [[ ! -f "${DOTFILES_DIR}/Brewfile" ]]; then
  echo "Error: ${DOTFILES_DIR}/Brewfile not found" >&2
  exit 1
fi

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

echo "==> Dumping current brew state"
# Newer brew bundle treats per-type flags as filters (passing --vscode would
# *only* dump vscode). Pass every type explicitly to get a complete dump.
brew bundle dump --file="$TMP" --force --formula --cask --tap --vscode 2>/dev/null \
  || brew bundle dump --file="$TMP" --force

# Extract "type:name" keys from a Brewfile-format file.
extract_keys() {
  awk '
    /^tap "/    { match($0, /"[^"]+"/); print "tap:"    substr($0, RSTART+1, RLENGTH-2); next }
    /^brew "/   { match($0, /"[^"]+"/); print "brew:"   substr($0, RSTART+1, RLENGTH-2); next }
    /^cask "/   { match($0, /"[^"]+"/); print "cask:"   substr($0, RSTART+1, RLENGTH-2); next }
    /^vscode "/ { match($0, /"[^"]+"/); print "vscode:" substr($0, RSTART+1, RLENGTH-2); next }
    /^mas "/    { match($0, /"[^"]+"/); print "mas:"    substr($0, RSTART+1, RLENGTH-2); next }
  ' "$1" | sort -u
}

tracked=$(for b in "${BUNDLES[@]}"; do extract_keys "$b"; done | sort -u)
current=$(extract_keys "$TMP")

new_keys=$(comm -23 <(echo "$current") <(echo "$tracked") || true)
removed_keys=$(comm -13 <(echo "$current") <(echo "$tracked") || true)

# Build menu of bundles
group_label() {
  local f="$1"
  local base
  base=$(basename "$f")
  if [[ "$base" == "Brewfile" ]]; then
    echo "essentials"
  else
    echo "${base#Brewfile.}"
  fi
}

print_menu() {
  echo "  Add to:"
  local i=1
  for b in "${BUNDLES[@]}"; do
    printf "    %d) %s\n" "$i" "$(group_label "$b")"
    ((i++))
  done
  echo "    s) skip"
}

drift=0

if [[ -z "${new_keys// }" ]]; then
  echo "==> Installed and tracked: in sync"
else
  echo "==> Installed but NOT in any Brewfile:"
  echo "$new_keys" | sed 's/^/    + /'
  drift=1
fi

if [[ -n "${removed_keys// }" ]]; then
  echo
  echo "==> Tracked but NOT installed (run 'brew bundle install' or prune):"
  echo "$removed_keys" | sed 's/^/    - /'
  drift=1
fi

if [[ "$CHECK_ONLY" == "yes" ]]; then
  echo
  if [[ "$drift" -eq 0 ]]; then
    echo "==> OK"
  else
    echo "==> Drift detected. Run without --check to route new entries interactively."
    echo "    To install missing tracked entries: brew bundle install --file=<Brewfile>"
  fi
  exit "$drift"
fi

# Interactive mode: route each new entry
if [[ -n "${new_keys// }" ]]; then
  echo
  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    type="${key%%:*}"
    name="${key#*:}"

    orig_line=$(grep -E "^${type} \"${name}\"" "$TMP" | head -n1)
    [[ -z "$orig_line" ]] && orig_line="${type} \"${name}\""

    echo
    echo "  ${orig_line}"
    print_menu
    read -rp "  Choice: " choice </dev/tty

    if [[ "$choice" =~ ^[Ss]$ ]]; then
      echo "    -> skipped"
    elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#BUNDLES[@]} )); then
      target="${BUNDLES[$((choice-1))]}"
      echo "$orig_line" >> "$target"
      echo "    -> $(group_label "$target")"
    else
      echo "    -> invalid choice, skipped"
    fi
  done <<< "$new_keys"
fi

echo
echo "==> Done. Review with: git -C \"$DOTFILES_DIR\" diff"
