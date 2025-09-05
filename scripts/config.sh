#!/bin/bash

# Remove all existing links
find $HOME -maxdepth 1 -type l -exec rm {} \;

# Link dotfiles
ln -s $HOME/.dotfiles/.gitconfig "${HOME}/.gitconfig"
ln -s $HOME/.dotfiles/.p10k.zsh "${HOME}/.p10k.zsh"
ln -s $HOME/.dotfiles/.zprofile "${HOME}/.zprofile"
ln -s $HOME/.dotfiles/.zshrc "${HOME}/.zshrc"
ln -s $HOME/.dotfiles/.tmux.conf "${HOME}/.tmux.conf"
ln -s $HOME/.dotfiles/.wezterm.lua "${HOME}/.wezterm.lua"
ln -s $HOME/.dotfiles/starship.toml "${HOME}/.config/starship.toml"
ln -s $HOME/.dotfiles/nvim "${HOME}/.config/nvim"

# Link vscode settings.json 
rm "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s $HOME/.dotfiles/vscode/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"
# Link icons
ln -s $HOME/.dotfiles/vscode/icons "${HOME}/.vscode/extensions/icons"

# Link keychron layout
ln -s $HOME/.dotfiles/keychron_q6_max_ansi_knob.layout.json "${HOME}/keychron_q6_max_ansi_knob.layout.json"

# Make scripts executable
chmod +x $HOME/.dotfiles/scripts/*.sh
