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

Brew bundle should have included `iTerm2`, `zsh`, `powerlevel10k`.

- Open iTerm2 -> Make iTerm2 Default Terminal
- Set font in settings

```bash
# list shells
cat /etc/shells
echo $SHELL
```

- Configure zsh as the default shell: `chsh -s $(which zsh)`

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## Symlink .dotfiles

```bash
./.dotfiles/link_dot_files.sh
```
