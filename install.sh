#!/usr/bin/env bash

# install.sh - Installer for git-inject and its documentation (Linux/macOS)

set -e

SCRIPT_NAME="git-inject"
HTML_NAME="git-inject.html"
MAN_NAME="git-inject.1"

# Identify the target directory for the script
if [ -d "$HOME/bin" ]; then
    BIN_DEST="$HOME/bin"
else
    BIN_DEST="/usr/local/bin"
fi

# Install the script
printf "Installing $SCRIPT_NAME to $BIN_DEST...\n"
if [ ! -w "$BIN_DEST" ]; then
    printf "Permission denied. Attempting with sudo...\n"
    sudo cp "$SCRIPT_NAME" "$BIN_DEST/"
    sudo chmod +x "$BIN_DEST/$SCRIPT_NAME"
else
    cp "$SCRIPT_NAME" "$BIN_DEST/"
    chmod +x "$BIN_DEST/$SCRIPT_NAME"
fi

# Install the Man page
MAN_DIR="/usr/local/share/man/man1"
printf "Installing man page to $MAN_DIR...\n"
if [ ! -d "$MAN_DIR" ]; then
    sudo mkdir -p "$MAN_DIR" 2>/dev/null || mkdir -p "$MAN_DIR"
fi

if [ ! -w "$MAN_DIR" ]; then
    sudo cp "$MAN_NAME" "$MAN_DIR/"
else
    cp "$MAN_NAME" "$MAN_DIR/"
fi

# Install the HTML documentation
HTML_PATH=$(git --html-path 2>/dev/null || true)

if [ -n "$HTML_PATH" ] && [ -d "$HTML_PATH" ]; then
    printf "Installing HTML documentation to $HTML_PATH...\n"
    if [ ! -w "$HTML_PATH" ]; then
        printf "Permission denied. Attempting with sudo...\n"
        sudo cp "$HTML_NAME" "$HTML_PATH/"
    else
        cp "$HTML_NAME" "$HTML_PATH/"
    fi
    printf "Success! You can now run 'git help inject' to view the documentation.\n"
else
    printf "Could not find Git HTML documentation path. HTML docs not installed.\n"
fi

printf "\nInstallation complete. Try:\n"
printf "  man git-inject    (For the man page)\n"
printf "  git inject        (To use the tool)\n"

# PATH check
if [[ ":$PATH:" != *":$BIN_DEST:"* ]]; then
    printf "\nWARNING: $BIN_DEST is not in your PATH.\n"
    printf "To use 'git inject' globally, add this to your .bashrc or .zshrc:\n"
    printf "  export PATH=\"\$PATH:$BIN_DEST\"\n"
fi
