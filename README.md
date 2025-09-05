# Setup

## Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/opt/homebrew/bin/brew shellenv)
```

- Install `Brewfile`

```bash
brew bundle
```

## Terminal

Brew bundle should have included `zsh` and other terminal stuff

```bash
# list shells
cat /etc/shells
echo $SHELL
```

- Set zsh as the default shell: `chsh -s $(which zsh)`
- Install oh-my-zsh, or use starship

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## Configure

```bash
./.dotfiles/scripts/config.sh
```
