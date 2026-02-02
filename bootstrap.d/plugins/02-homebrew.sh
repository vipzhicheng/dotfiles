#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Homebrew Package Manager
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="homebrew"
PLUGIN_DEPENDS="xcode"
PLUGIN_DESCRIPTION="Install Homebrew package manager"

plugin_homebrew_main() {
    log_step "Installing Homebrew"

    # Check if already installed
    if command_exists brew; then
        log_success "Homebrew already installed at: $(which brew)"
        log_info "Homebrew version: $(brew --version | head -n 1)"

        # Update Homebrew
        log_info "Updating Homebrew..."
        brew update

        return 0
    fi

    log_info "Homebrew not found, installing..."

    # Install Homebrew
    local install_script="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

    if /bin/bash -c "$(curl -fsSL $install_script)"; then
        log_success "Homebrew installed successfully"
    else
        log_error "Homebrew installation failed"
        return 1
    fi

    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        # Intel
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Verify installation
    if command_exists brew; then
        log_success "Homebrew is now available"
        log_info "Homebrew version: $(brew --version | head -n 1)"
        return 0
    else
        log_error "Homebrew installation verification failed"
        return 1
    fi
}
