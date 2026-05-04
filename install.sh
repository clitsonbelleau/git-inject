#!/usr/bin/env bash

# install.sh - Installer for git-inject and its documentation (Linux/macOS)

set -e

SCRIPT_NAME="git-inject"
HTML_NAME="git-inject.html"
MAN_NAME="git-inject.1"

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

header() { printf "\n${BOLD}${CYAN}==>${NC} ${BOLD}%s${NC}\n" "$1"; }
success() { printf "  ${GREEN}[OK]${NC} %s\n" "$1"; }
error() { printf "  ${RED}[FAIL]${NC} %s\n" "$1"; }
warn() { printf "  ${YELLOW}[!]${NC} %s\n" "$1"; }

# Identify the target directory for the script
if [ -d "$HOME/bin" ]; then
    BIN_DEST="$HOME/bin"
else
    BIN_DEST="/usr/local/bin"
fi

# --- Script installation

header "Installing $SCRIPT_NAME tool"
if [ ! -w "$BIN_DEST" ]; then
    warn "Permission denied for $BIN_DEST. Attempting with sudo..."
    sudo cp "$SCRIPT_NAME" "$BIN_DEST/"
    sudo chmod +x "$BIN_DEST/$SCRIPT_NAME"
else
    cp "$SCRIPT_NAME" "$BIN_DEST/"
    chmod +x "$BIN_DEST/$SCRIPT_NAME"
fi
success "Installed script to: $BIN_DEST/$SCRIPT_NAME"

# --- Man page

MAN_DIR="/usr/local/share/man/man1"
header "Installing man page"
if [ ! -d "$MAN_DIR" ]; then
    sudo mkdir -p "$MAN_DIR" 2>/dev/null || mkdir -p "$MAN_DIR"
fi

if [ ! -w "$MAN_DIR" ]; then
    sudo cp "$MAN_NAME" "$MAN_DIR/"
else
    cp "$MAN_NAME" "$MAN_DIR/"
fi
success "Man page installed to $MAN_DIR"

# --- HTML documentation

HTML_PATH=$(git --html-path 2>/dev/null || true)

if [ -n "$HTML_PATH" ] && [ -d "$HTML_PATH" ]; then
    header "Installing HTML documentation"
    if [ ! -w "$HTML_PATH" ]; then
        warn "Permission denied for $HTML_PATH. Attempting with sudo..."
        sudo cp "$HTML_NAME" "$HTML_PATH/"
    else
        cp "$HTML_NAME" "$HTML_PATH/"
    fi
    success "Installed documentation to system Git docs."
    printf "     You can now run 'git help inject' to view the documentation.\n"
else
    warn "Could not find Git HTML documentation path. HTML docs not installed."
fi

printf "\n${BOLD}${GREEN}Done! Installation complete.${NC}\n"

# PATH check
if [[ ":$PATH:" != *":$BIN_DEST:"* ]]; then
    printf "\n${YELLOW}[!] WARNING: $BIN_DEST is not in your PATH.${NC}\n"
    printf "To use 'git inject' globally, add this to your .bashrc or .zshrc:\n"
    printf "  ${BOLD}export PATH=\"\$PATH:$BIN_DEST\"${NC}\n"
fi

printf "\n${BOLD}Try it out:${NC}\n"
printf "  ${CYAN}man git-inject${NC}\n"
printf "  ${CYAN}git inject${NC}\n"
printf "  ${CYAN}git help inject${NC}\n"
