#!/usr/bin/env bash

# install.sh - Installer for git-inject and its documentation
#
# Copyright (C) 2026  Clitson Belleau <dev@clitson.nl>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

if [ "$1" != "--local" ]; then
  repo="git-inject"
  branch="main"
  ref="$repo/archive/refs/heads"
  url="https://git.clitson.nl/$ref/$branch.zip"
  folder="$repo-$branch"
  file="$folder.zip"

  curl -sL "$url" -o "$file"
  unzip -q -o "$file"
  rm -f -- "$file"

  ORIG_DIR="$PWD"
  trap 'cd "$ORIG_DIR" && rm -rf "$folder"' EXIT

  cd "$folder" || exit 1
fi


SCRIPT_NAME="git-inject"
HTML_DOC="git-inject.html"
MAN_DOC="git-inject.1"

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

header() { printf "\n${BOLD}${CYAN}==>${NC} ${BOLD}%s${NC}\n" "$1"; }
success() { printf "    ${GREEN}[OK]${NC} %s\n" "$1"; }
error() { printf "    ${RED}[FAIL]${NC} %s\n" "$1"; }
warn() { printf "    ${YELLOW}[!]${NC} %s\n" "$1"; }


# Identify the target directory for the script
if [ -d "$HOME/.local/bin" ]; then
    BIN_DEST="$HOME/.local/bin"
else
    BIN_DEST="$HOME/bin"
    if [ ! -d "$BIN_DEST" ]; then
        printf "  Creating local bin directory at %s...\n" "$BIN_DEST"
        mkdir -p "$BIN_DEST"
    fi
fi


header "Installing $SCRIPT_NAME"
if [ ! -w "$BIN_DEST" ]; then
    error "Permission denied for $BIN_DEST."
    exit 1
fi

cp "$SCRIPT_NAME" "$BIN_DEST/"
chmod +x "$BIN_DEST/$SCRIPT_NAME"
success "Installed script to: $BIN_DEST/$SCRIPT_NAME"


header "Installing man page"
MAN_DIR="/usr/local/share/man/man1"

if [ -d "$MAN_DIR" ] && [ -w "$MAN_DIR" ]; then
    cp "$MAN_DOC" "$MAN_DIR/"
    success "Man page installed to system docs ($MAN_DIR)"
else
    LOCAL_MAN_DIR="$HOME/.local/share/man/man1"
    mkdir -p "$LOCAL_MAN_DIR"
    cp "$MAN_DOC" "$LOCAL_MAN_DIR/"
    success "Man page installed locally to $LOCAL_MAN_DIR"
fi


header "Installing HTML documentation"
HTML_PATH=$(git --html-path 2>/dev/null || true)

if [ -n "$HTML_PATH" ] && [ -d "$HTML_PATH" ] && [ -w "$HTML_PATH" ]; then
    cp "$HTML_DOC" "$HTML_PATH/"
    success "Installed documentation to system Git docs."
    printf "         You can now run 'git help inject' to view the documentation.\n"
else
    if [ -n "$HTML_PATH" ] && [ -d "$HTML_PATH" ]; then
        warn "Permission denied for system Git docs at $HTML_PATH."
    else
        warn "Could not find Git HTML documentation path."
    fi
    LOCAL_HTML_DEST="$BIN_DEST/docs"
    mkdir -p "$LOCAL_HTML_DEST"
    cp "$HTML_DOC" "$LOCAL_HTML_DEST/"
    success "Installed documentation locally to: $LOCAL_HTML_DEST"
    printf "         You can open it manually or create an alias.\n"
fi


case ":$PATH:" in
    *":$BIN_DEST:"*) ;;
    *)
        case "$(uname -s)" in
            MINGW*|CYGWIN*|MSYS*)
                header "Updating Windows User PATH"
                WIN_BIN_DEST=$(cygpath -w "$BIN_DEST" 2>/dev/null || echo "$BIN_DEST")
                powershell.exe -NoProfile -Command '
                    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User");
                    $WinBinDest = "'"$WIN_BIN_DEST"'";
                    if ($UserPath -split ";" -notcontains $WinBinDest) {
                        Write-Host "  Adding $WinBinDest to your User PATH..." -ForegroundColor Cyan;
                        $NewPath = "$UserPath;$WinBinDest".Trim(";");
                        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User");
                        Write-Host "  [OK] PATH updated successfully." -ForegroundColor Green;
                        Write-Host "       You will need to restart your terminal for this to take effect." -ForegroundColor Gray;
                    }
                '
                ;;
            *)
                printf "\n${YELLOW}[!] WARNING: $BIN_DEST is not in your PATH.${NC}\n"
                printf "To use '\''git inject'\'' globally, add this to your .bashrc or .zshrc:\n"
                printf "  ${BOLD}export PATH=\"\$PATH:$BIN_DEST\"${NC}\n"
                ;;
        esac
        ;;
esac


printf "\n${BOLD}Try it out:${NC}\n"
printf "  ${CYAN}man git-inject${NC}\n"
printf "  ${CYAN}git inject${NC}\n"
printf "  ${CYAN}git help inject${NC}\n"
