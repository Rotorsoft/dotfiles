#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new Mac:
#   1. Ensures Xcode Command Line Tools (clang/make/headers for node-gyp)
#   2. Installs Homebrew if missing
#   3. Installs Brewfile (essentials) — always
#   4. For every other Brewfile.<group>, prompts y/n (or honors flags)
#   5. Sets zsh as default shell
#   6. Runs scripts/config.sh to symlink dotfiles
#
# Flags:
#   --all                 Install every Brewfile.* without prompting
#   --none                Install essentials only, skip the rest
#   --with a,b,c          Install only these groups (comma-separated suffixes)
#   --skip a,b,c          Skip these groups, prompt for the rest
#   -h, --help            Show help

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
MODE=""           # all | none | with | skip | (empty=prompt)
WITH_LIST=""
SKIP_LIST=""

usage() { sed -n '3,18p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)   MODE="all";  shift ;;
    --none)  MODE="none"; shift ;;
    --with)  MODE="with"; WITH_LIST="$2"; shift 2 ;;
    --skip)  MODE="skip"; SKIP_LIST="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; usage; exit 1 ;;
  esac
done

in_csv() {
  local needle="$1" csv="$2"
  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    [[ "${item// }" == "$needle" ]] && return 0
  done
  return 1
}

# 1. Xcode Command Line Tools (clang, make, headers — needed for node-gyp builds)
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools"
  xcode-select --install
  echo "    Re-run this script after the GUI installer finishes."
  exit 0
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if   [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]];   then eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# 2b. Repair Homebrew git repo if corrupted (brew update fails without it)
brew_repo="$(brew --prefix)/Homebrew"
if [[ -d "$brew_repo" ]] && ! git -C "$brew_repo" rev-parse --git-dir >/dev/null 2>&1; then
  echo "==> Repairing Homebrew git repository"
  git -C "$brew_repo" init
  git -C "$brew_repo" remote add origin https://github.com/Homebrew/brew 2>/dev/null || true
  git -C "$brew_repo" fetch origin
  git -C "$brew_repo" reset --hard origin/master
fi

# 2c. Fix zsh completion dir ownership (Homebrew packages write there)
for zsh_dir in /usr/local/share/zsh /usr/local/share/zsh/site-functions; do
  if [[ -d "$zsh_dir" ]] && [[ ! -w "$zsh_dir" ]]; then
    echo "==> Fixing ownership of $zsh_dir"
    sudo chown -R "$(whoami)" "$zsh_dir"
    chmod u+w "$zsh_dir"
  fi
done

# 3. Essentials — always
echo "==> Installing essentials (Brewfile)"
brew bundle --file="${DOTFILES_DIR}/Brewfile"

# 3. Optional Brewfiles — discover dynamically
shopt -s nullglob
for bundle in "${DOTFILES_DIR}"/Brewfile.*; do
  group=$(basename "$bundle" | sed 's/^Brewfile\.//')
  install_it="no"

  case "$MODE" in
    all)  install_it="yes" ;;
    none) install_it="no"  ;;
    with) in_csv "$group" "$WITH_LIST" && install_it="yes" ;;
    skip) in_csv "$group" "$SKIP_LIST" || install_it="ask" ;;
    "")   install_it="ask" ;;
  esac

  if [[ "$install_it" == "ask" ]]; then
    read -rp "Install ${group}? [y/N] " ans </dev/tty
    [[ "$ans" =~ ^[Yy] ]] && install_it="yes" || install_it="no"
  fi

  if [[ "$install_it" == "yes" ]]; then
    echo "==> Installing ${group}"
    brew bundle --file="$bundle"
  fi
done

# 4. Default shell
if [[ "${SHELL:-}" != *zsh ]]; then
  echo "==> Setting zsh as default shell"
  chsh -s "$(which zsh)"
fi

# 5. Symlink dotfiles
echo "==> Linking dotfiles"
"${DOTFILES_DIR}/scripts/config.sh"

cat <<EOF

==> Done.
Next steps:
  - Open a new terminal
  - Install Node:        nvm install --lts
  - Verify:              node -v && pnpm -v && bun -v
EOF
