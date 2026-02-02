#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  macOS Bootstrap Script
#
#  A modular, plugin-based system for setting up a new macOS machine
#
#  Features:
#  - Plugin architecture with dependency resolution
#  - Idempotent operations (safe to run multiple times)
#  - Dry-run mode for testing
#  - Automatic dependency ordering
#  - Comprehensive error handling
#
#  Usage:
#    ./bootstrap.sh [options]
#
#  Options:
#    --dry-run              Show what would be done without doing it
#    --list                 List all available plugins
#    --debug                Enable debug output
#    --continue-on-error    Continue even if a plugin fails
#    --skip-confirmation    Skip all confirmation prompts
#    --help                 Show this help message
# ────────────────────────────────────────────────────────────────

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_LIB_DIR="$SCRIPT_DIR/bootstrap.d/lib"
BOOTSTRAP_PLUGINS_DIR="$SCRIPT_DIR/bootstrap.d/plugins"

# Load utility functions
# shellcheck source=/dev/null
source "$BOOTSTRAP_LIB_DIR/utils.sh"

# Load plugin system
# shellcheck source=/dev/null
source "$BOOTSTRAP_LIB_DIR/plugin_system.sh"

# ────────────────────────────────────────────────────────────────
#  Command Line Argument Parsing
# ────────────────────────────────────────────────────────────────

DRY_RUN=false
LIST_PLUGINS=false
SKIP_CONFIRMATION=false

show_help() {
    cat << EOF
macOS Bootstrap Script

A modular, plugin-based system for setting up a new macOS machine.

Usage:
  ./bootstrap.sh [options]

Options:
  --dry-run              Show what would be done without doing it
  --list                 List all available plugins
  --debug                Enable debug output
  --continue-on-error    Continue even if a plugin fails
  --skip-confirmation    Skip all confirmation prompts (auto-yes)
  --help                 Show this help message

Examples:
  # Normal run with confirmations
  ./bootstrap.sh

  # Dry run to see what would happen
  ./bootstrap.sh --dry-run

  # List all plugins and their dependencies
  ./bootstrap.sh --list

  # Run with debug output
  ./bootstrap.sh --debug

  # Fully automated run (no prompts)
  ./bootstrap.sh --skip-confirmation

Environment Variables:
  BOOTSTRAP_DEBUG            Enable debug mode (true/false)
  BOOTSTRAP_CONTINUE_ON_ERROR Continue on plugin errors (true/false)

Plugin System:
  Plugins are located in: $BOOTSTRAP_PLUGINS_DIR
  Each plugin is a self-contained script with metadata:
    - PLUGIN_NAME: Unique identifier
    - PLUGIN_DEPENDS: Space-separated list of dependencies
    - PLUGIN_DESCRIPTION: Human-readable description
    - plugin_<name>_main: Main function to execute

EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list)
            LIST_PLUGINS=true
            shift
            ;;
        --debug)
            export BOOTSTRAP_DEBUG=true
            shift
            ;;
        --continue-on-error)
            export BOOTSTRAP_CONTINUE_ON_ERROR=true
            shift
            ;;
        --skip-confirmation)
            SKIP_CONFIRMATION=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# ────────────────────────────────────────────────────────────────
#  Pre-flight Checks
# ────────────────────────────────────────────────────────────────

preflight_checks() {
    log_step "Running pre-flight checks"

    # Ensure running on macOS
    if ! is_macos; then
        log_error "This script is designed for macOS only"
        log_error "Detected OS: $OSTYPE"
        exit 1
    fi

    log_success "Running on macOS $(get_macos_version)"

    # Ensure not running as root
    ensure_not_root

    # Check required directories
    if [[ ! -d "$BOOTSTRAP_LIB_DIR" ]]; then
        log_error "Bootstrap library directory not found: $BOOTSTRAP_LIB_DIR"
        exit 1
    fi

    if [[ ! -d "$BOOTSTRAP_PLUGINS_DIR" ]]; then
        log_error "Bootstrap plugins directory not found: $BOOTSTRAP_PLUGINS_DIR"
        exit 1
    fi

    log_success "Pre-flight checks passed"
}

# ────────────────────────────────────────────────────────────────
#  Main Execution
# ────────────────────────────────────────────────────────────────

main() {
    # Print banner
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              macOS Bootstrap System                        ║"
    echo "║                                                            ║"
    echo "║  Plugin-based setup for a new macOS development machine   ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo

    # Run pre-flight checks
    preflight_checks
    echo

    # Load all plugins
    load_plugins "$BOOTSTRAP_PLUGINS_DIR"
    echo

    # List plugins if requested
    if $LIST_PLUGINS; then
        list_plugins
        exit 0
    fi

    # Resolve dependencies
    if ! resolve_dependencies; then
        log_error "Failed to resolve plugin dependencies"
        exit 1
    fi
    echo

    # Show execution plan
    log_step "Execution Plan"
    echo
    for plugin_name in "${PLUGIN_EXECUTION_ORDER[@]}"; do
        local desc="${PLUGIN_DESCRIPTIONS[$plugin_name]}"
        echo "  $plugin_name - $desc"
    done
    echo

    # Ask for confirmation unless skipped or dry-run
    if ! $DRY_RUN && ! $SKIP_CONFIRMATION; then
        if ! ask_confirmation "Proceed with bootstrap?" "y"; then
            log_info "Bootstrap cancelled by user"
            exit 0
        fi
        echo
    fi

    # Execute plugins
    if $DRY_RUN; then
        execute_plugins --dry-run
    else
        execute_plugins
    fi

    # Final message
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              Bootstrap Complete!                           ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo
    log_success "Your macOS machine is now set up!"
    log_info "You may need to:"
    log_info "  - Restart your terminal or run: source ~/.zshrc"
    log_info "  - Log out and log back in for shell changes to take effect"
    echo
}

# Run main function
main "$@"
