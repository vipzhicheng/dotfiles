#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Quick Plugin Runner
#
#  Convenience script for running individual plugins
#
#  Usage:
#    ./run-plugin.sh <plugin-name> [--dry-run] [--only]
#
#  Examples:
#    ./run-plugin.sh brewfile --dry-run   # Preview brewfile update
#    ./run-plugin.sh dotfiles --only      # Only run dotfiles (skip deps)
#    ./run-plugin.sh homebrew             # Run homebrew with deps
# ────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default options
PLUGIN_NAME=""
DRY_RUN=""
ONLY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN="--dry-run"
            shift
            ;;
        --only|-o)
            ONLY="--plugin-only"
            shift
            ;;
        --help|-h)
            cat << EOF
Quick Plugin Runner

Usage:
  ./run-plugin.sh <plugin-name> [options]

Options:
  --dry-run, -d    Preview without executing
  --only, -o       Skip plugin dependencies
  --help, -h       Show this help

Available plugins:
  xcode       - Install Xcode Command Line Tools
  homebrew    - Install/update Homebrew
  zsh         - Install/update Zsh
  ohmyzsh     - Install/update Oh My Zsh
  brewfile    - Install packages from Brewfile
  dotfiles    - Create dotfiles symlinks

Examples:
  # Preview brewfile update
  ./run-plugin.sh brewfile --dry-run

  # Just update dotfiles symlinks
  ./run-plugin.sh dotfiles --only

  # Run homebrew with dependencies
  ./run-plugin.sh homebrew

  # Update Brewfile packages (most common use case)
  ./run-plugin.sh brewfile
EOF
            exit 0
            ;;
        *)
            if [[ -z "$PLUGIN_NAME" ]]; then
                PLUGIN_NAME="$1"
            else
                echo "Error: Unknown argument: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if plugin name provided
if [[ -z "$PLUGIN_NAME" ]]; then
    echo "Error: Plugin name required" >&2
    echo "Run: ./run-plugin.sh --help" >&2
    exit 1
fi

# Build command
if [[ -n "$ONLY" ]]; then
    CMD="$SCRIPT_DIR/bootstrap.sh --plugin-only $PLUGIN_NAME $DRY_RUN"
else
    CMD="$SCRIPT_DIR/bootstrap.sh --plugin $PLUGIN_NAME $DRY_RUN"
fi

# Run
echo "Running: $CMD"
echo
$CMD
