#!/bin/bash
DOTFILES_DIR=$HOME/.dotfiles

# Loop through all dotfiles in the .dotfiles directory
for file in $DOTFILES_DIR/.*; do
  # Skip . and ..
  if [[ $(basename "$file") == "." || $(basename "$file") == ".." ]]; then
    continue
  fi
  filename=$(basename "$file")
  # Create a symlink in the home directory
  ln -s "$file" $HOME/"$filename"
done

# Link vscode settings.json 
rm "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s $HOME/.dotfiles/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

# Link icons
ln -s $HOME/.dotfiles/icons "${HOME}/.vscode/extensions/icons"