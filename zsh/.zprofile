# Runs once per login shell — the right place for one-time setup like
# Homebrew shellenv (expensive) and tool initializations that don't need
# to re-run for every subprocess.

# appends existing directory or symlink to PATH
append_path() {
  p=$(realpath "$1")
  if [ -d "$p" ] || [ -f "$p" ]; then
    case ":$PATH:" in
      *":$1:"*)
        # do nothing when found
        ;;
      *)
        export PATH="$PATH:$1"
        ;;
    esac
    return 0
  else
    echo "Path not found: $1"
    return 1
  fi
}

# Optional, opt-in tool environments. Node versions are managed by mise
# (see .zshrc) — the node branch here just sets up the pnpm/corepack
# ecosystem and aliases.
use_tool() {
  case $1 in
    dotnet)
      append_path "/usr/local/share/dotnet" || return
      echo "✓ .NET"
      ;;
    node)
      export PNPM_HOME="$HOME/Library/pnpm"
      mkdir -p "$PNPM_HOME"
      append_path "$PNPM_HOME" || true
      export COREPACK_ENABLE_STRICT=0
      alias p=pnpm
      echo "✓ node"
      ;;
    gcloud)
      source $HOME/google-cloud-sdk/path.zsh.inc || return
      source $HOME/google-cloud-sdk/completion.zsh.inc || return
      echo "✓ gcloud"
      ;;
    *)
      echo "Usage: use_tool [dotnet|node|gcloud]"
      ;;
  esac
}

# homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
append_path "$HOMEBREW_PREFIX/bin"
append_path "$HOMEBREW_PREFIX/sbin"
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# init my tools (pnpm/corepack ecosystem)
use_tool node
