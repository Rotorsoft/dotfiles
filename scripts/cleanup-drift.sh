#!/usr/bin/env bash
set -euo pipefail

# Show packages installed locally but not tracked in any Brewfile, and emit
# the commands needed to remove them. Auto-installed Homebrew dependencies
# (anything not in `brew leaves`) are skipped — they'd just get re-pulled
# on the next install.
#
# Usage:
#   cleanup-drift.sh           # print uninstall commands (safe, no-op)
#   cleanup-drift.sh --apply   # run them after a y/N confirmation

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
APPLY="no"

case "${1:-}" in
  --apply)   APPLY="yes" ;;
  -h|--help) sed -n '3,12p' "$0"; exit 0 ;;
  "") ;;
  *) echo "Unknown flag: $1" >&2; exit 1 ;;
esac

shopt -s nullglob
BUNDLES=("${DOTFILES_DIR}/Brewfile" "${DOTFILES_DIR}"/Brewfile.*)

TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
brew bundle dump --file="$TMP" --force --formula --cask --tap --vscode 2>/dev/null

extract_keys() {
  awk '
    /^tap "/    { match($0, /"[^"]+"/); print "tap:"    substr($0, RSTART+1, RLENGTH-2); next }
    /^brew "/   { match($0, /"[^"]+"/); print "brew:"   substr($0, RSTART+1, RLENGTH-2); next }
    /^cask "/   { match($0, /"[^"]+"/); print "cask:"   substr($0, RSTART+1, RLENGTH-2); next }
    /^vscode "/ { match($0, /"[^"]+"/); print "vscode:" substr($0, RSTART+1, RLENGTH-2); next }
  ' "$1" | sort -u
}

tracked=$(for b in "${BUNDLES[@]}"; do extract_keys "$b"; done | sort -u)
current=$(extract_keys "$TMP")
drift=$(comm -23 <(echo "$current") <(echo "$tracked") || true)

if [[ -z "${drift// }" ]]; then
  echo "==> No drift. Machine matches Brewfiles."
  exit 0
fi

# Cache `brew leaves` so we can skip auto-installed deps
LEAVES=$(brew leaves)
is_leaf() { grep -Fxq "$1" <<< "$LEAVES"; }

declare -a CMDS
declare -a SKIPPED_DEPS

while IFS= read -r key; do
  [[ -z "$key" ]] && continue
  type="${key%%:*}"
  name="${key#*:}"
  case "$type" in
    brew)
      if is_leaf "$name"; then
        CMDS+=("brew uninstall $name")
      else
        SKIPPED_DEPS+=("$name")
      fi
      ;;
    cask)   CMDS+=("brew uninstall --cask $name") ;;
    tap)    CMDS+=("brew untap $name") ;;
    vscode) CMDS+=("code --uninstall-extension $name") ;;
  esac
done <<< "$drift"

if [[ ${#SKIPPED_DEPS[@]} -gt 0 ]]; then
  echo "==> Skipping auto-installed deps (not in 'brew leaves'):"
  printf '    %s\n' "${SKIPPED_DEPS[@]}"
  echo
fi

if [[ ${#CMDS[@]} -eq 0 ]]; then
  echo "==> Nothing to remove (only dependency noise)."
  exit 0
fi

echo "==> Drift to remove:"
printf '    %s\n' "${CMDS[@]}"

if [[ "$APPLY" != "yes" ]]; then
  echo
  echo "Re-run with --apply to execute these."
  exit 0
fi

echo
read -rp "Run ${#CMDS[@]} command(s) above? [y/N] " ans </dev/tty
[[ "$ans" =~ ^[Yy] ]] || { echo "Aborted."; exit 0; }

for cmd in "${CMDS[@]}"; do
  echo "==> $cmd"
  eval "$cmd" || echo "    (failed, continuing)"
done

echo
echo "==> Done. Re-check with: $DOTFILES_DIR/scripts/update-brewfiles.sh --check"
