#!/bin/bash

# Remove all existing links
find $HOME -maxdepth 1 -type l -exec rm {} \;

# Link dotfiles
ln -s $HOME/.dotfiles/.gitconfig "${HOME}/.gitconfig"
ln -s $HOME/.dotfiles/.p10k.zsh "${HOME}/.p10k.zsh"
ln -s $HOME/.dotfiles/.zprofile "${HOME}/.zprofile"
ln -s $HOME/.dotfiles/.zshrc "${HOME}/.zshrc"

# Link vscode settings.json 
rm "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s $HOME/.dotfiles/settings.json "${HOME}/Library/Application Support/Code/User/settings.json"

# Link icons
ln -s $HOME/.dotfiles/icons "${HOME}/.vscode/extensions/icons"

# Link iTerm2 settings
ln -s $HOME/.dotfiles/com.googlecode.iterm2.plist "${HOME}/Library/Preferences/com.googlecode.iterm2.plist"

# Link keychron layout
ln -s $HOME/.dotfiles/keychron_q6_max_ansi_knob.layout.json "${HOME}/keychron_q6_max_ansi_knob.layout.json"
