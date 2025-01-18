# appends existing directory or symlink to PATH
append_path() {
  p=$(realpath "$1")
  if [ -d "$p" ] || [ -f "$p" ]; then
    case ":$PATH:" in
      *":$1:"*)
        # do nothing when found 
        ;; 
      *) 
        # otherwise append to path
        export PATH="$PATH:$1" 
        echo "Appended $1 to PATH"
        ;;
    esac
    return 0 # success
  else
    echo "Path not found: $1"
    return 1 # failure
  fi
}

# configs tool-specific environments
use_tool() {
  case $1 in
    java)
      append_path "$HOMEBREW_PREFIX/opt/openjdk/bin" || return
      echo "✅ Java"
      ;;
    dotnet)
      append_path "/usr/local/share/dotnet" || return
      echo "✅ .NET"
      ;;
    modular)
      export MODULAR_HOME="$HOMEBREW_PREFIX/bin/.modular"
      append_path "$MODULAR_HOME/pkg/packages.modular.com_mojo/bin" || return
      echo "✅ Modular"
      ;;
    node)
      # pnpm 
      export PNPM_HOME="$HOME/Library/pnpm"
      append_path "$PNPM_HOME" || return
      export COREPACK_ENABLE_STRICT=0 # to allow new versions
      alias p=pnpm
      # nvm
      . "$HOME/.nvm/nvm.sh" || return
      echo "✅ Node"
      ;;
    psql)
      append_path "$HOMEBREW_PREFIX/opt/libpq/bin" || return
      echo "✅ psql"
      ;;
    gcloud)
      source $HOME/google-cloud-sdk/path.zsh.inc || return
      source $HOME/google-cloud-sdk/completion.zsh.inc || return
      echo "✅ gcloud"
      ;;
    bun)
      source "$HOME/.bun/_bun" || return
      echo "✅ Bun"
      ;;
    python)
      alias python=python3
      alias py=python3
      alias pip=pip3
      echo "✅ Python aliases"
      ;;
    *)
      echo "Usage: use_tool [java|dotnet|modular|node|psql|gcloud|bun|python]"
      ;;
  esac
}

# homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
append_path "$HOMEBREW_PREFIX/bin"
append_path "$HOMEBREW_PREFIX/sbin"
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# zoxide
eval "$(zoxide init zsh)"

# init my tools
use_tool node
use_tool psql
