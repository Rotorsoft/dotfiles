#!/bin/bash

# Script to back up and modify Visual Studio Code's `workbench.html` file.
# Adds a <style> section with contents from `vscode-custom.css`.
# Designed for installations via Homebrew in root directory.

# Path to the Visual Studio Code workbench file
VSCODE_WORKBENCH_PATH="$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/code/electron-sandbox/workbench"

# File paths
WORKBENCH_FILE="${VSCODE_WORKBENCH_PATH}/workbench.html"
BACKUP_FILE="${WORKBENCH_FILE}.bak"
CUSTOM_CSS="vscode-custom.css"

# Check if the workbench file exists
if [ ! -f "$WORKBENCH_FILE" ]; then
  echo "Error: workbench.html not found at $WORKBENCH_FILE"
  exit 1
fi

# Check if the custom CSS file exists
if [ ! -f "$CUSTOM_CSS" ]; then
  echo "Error: $CUSTOM_CSS not found in the current directory"
  exit 1
fi

# Backup the original workbench.html file if not already backed up
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backing up the original workbench.html file..."
  cp "$WORKBENCH_FILE" "$BACKUP_FILE"
  echo "Backup created at $BACKUP_FILE"
else
  echo "Backup already exists at $BACKUP_FILE"
fi

# Insert the custom CSS directly into the <head> section of the HTML
echo "Modifying workbench.html to include custom CSS..."
awk -v cssfile="$CUSTOM_CSS" '
BEGIN {
  # Read the custom CSS file into the variable
  while ((getline line < cssfile) > 0) {
    css = css line "\n"
  }
  close(cssfile)
}
/<\/head>/ {
  # Insert the CSS before the closing </head> tag
  print css
}
{ print }
' "$BACKUP_FILE" | sudo tee "$WORKBENCH_FILE" > /dev/null

echo "Modified workbench.html successfully created at $WORKBENCH_FILE"

# Completion message
echo "Done! Restart Visual Studio Code to see the changes."
