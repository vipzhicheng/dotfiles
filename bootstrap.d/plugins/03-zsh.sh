#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Zsh Shell
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="zsh"
PLUGIN_DEPENDS="homebrew"
PLUGIN_DESCRIPTION="Install/Update Zsh shell (macOS has built-in zsh, but we ensure latest version)"

plugin_zsh_main() {
    log_step "Setting up Zsh"

    # Check if zsh exists (macOS has built-in zsh)
    if command_exists zsh; then
        local current_version
        current_version=$(zsh --version | awk '{print $2}')
        log_info "Zsh already installed: version $current_version"
    else
        log_warning "Zsh not found (unusual for macOS), will install via Homebrew"
    fi

    # Install/update zsh via Homebrew to get latest version
    log_info "Installing/updating Zsh via Homebrew..."
    if brew install zsh 2>/dev/null || brew upgrade zsh 2>/dev/null; then
        log_success "Zsh installed/updated via Homebrew"
    else
        log_warning "Failed to install Zsh via Homebrew, but may already be available"
    fi

    # Get Homebrew zsh path
    local brew_zsh_path
    if [[ -f "/opt/homebrew/bin/zsh" ]]; then
        brew_zsh_path="/opt/homebrew/bin/zsh"
    elif [[ -f "/usr/local/bin/zsh" ]]; then
        brew_zsh_path="/usr/local/bin/zsh"
    else
        brew_zsh_path=$(which zsh)
    fi

    log_info "Zsh path: $brew_zsh_path"
    log_info "Zsh version: $(zsh --version)"

    # Add Homebrew zsh to allowed shells if not already there
    if ! grep -q "$brew_zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding $brew_zsh_path to /etc/shells"
        echo "$brew_zsh_path" | sudo tee -a /etc/shells >/dev/null
        log_success "Added to /etc/shells"
    else
        log_info "Zsh already in /etc/shells"
    fi

    # Change default shell to zsh if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Changing default shell to zsh..."
        if chsh -s "$brew_zsh_path"; then
            log_success "Default shell changed to zsh"
            log_warning "You may need to restart your terminal or log out/in for changes to take effect"
        else
            log_warning "Failed to change default shell. You can manually run: chsh -s $brew_zsh_path"
        fi
    else
        log_success "Zsh is already the default shell"
    fi

    return 0
}
