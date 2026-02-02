#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Utility Functions for Bootstrap System
# ────────────────────────────────────────────────────────────────

# Prevent multiple sourcing
[[ -n "${BOOTSTRAP_UTILS_LOADED:-}" ]] && return 0
readonly BOOTSTRAP_UTILS_LOADED=1

# Color codes for output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

log_debug() {
    if [[ "${BOOTSTRAP_DEBUG:-}" == "true" ]]; then
        echo -e "${COLOR_PURPLE}[DEBUG]${COLOR_RESET} $*" >&2
    fi
}

log_step() {
    echo -e "${COLOR_CYAN}==>${COLOR_RESET} $*"
}

# Ask user for confirmation
ask_confirmation() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -rp "$prompt" response
    response="${response:-$default}"

    [[ "$response" =~ ^[Yy]$ ]]
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Get macOS version
get_macos_version() {
    if is_macos; then
        sw_vers -productVersion
    else
        echo "N/A"
    fi
}

# Create backup of a file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up $file to $backup"
        cp "$file" "$backup"
    fi
}

# Check if script is run with sudo/root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Ensure NOT running as root
ensure_not_root() {
    if is_root; then
        log_error "This script should not be run as root/sudo"
        exit 1
    fi
}

# Create symlink with backup
safe_symlink() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        backup_file "$target"
        rm -f "$target"
    elif [[ -L "$target" ]]; then
        # Remove existing symlink
        rm -f "$target"
    fi

    ln -sf "$source" "$target"
    log_debug "Created symlink: $target -> $source"
}
