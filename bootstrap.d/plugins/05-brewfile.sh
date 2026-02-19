#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Brewfile Installation
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="brewfile"
PLUGIN_DEPENDS="homebrew"
PLUGIN_DESCRIPTION="Install packages from Brewfile"

plugin_brewfile_main() {
    log_step "Installing packages from Brewfile"

    # Get dotfiles root directory
    local dotfiles_root
    dotfiles_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    local brewfile="$dotfiles_root/brew/Brewfile"

    if [[ ! -f "$brewfile" ]]; then
        log_warning "Brewfile not found at: $brewfile"
        log_info "Skipping Brewfile installation"
        return 0
    fi

    log_info "Found Brewfile at: $brewfile"

    # Check if brew bundle is available
    if ! brew bundle --help &>/dev/null; then
        log_error "brew bundle command not available"
        return 1
    fi

    # Show what will be installed
    log_info "Checking Brewfile..."
    brew bundle check --file="$brewfile" --verbose || true

    echo
    if ask_confirmation "Install all packages from Brewfile?" "n"; then
        log_info "Installing packages (this may take a while)..."

        if brew bundle install --file="$brewfile" --verbose; then
            log_success "Brewfile packages installed successfully"
        else
            log_warning "Some packages may have failed to install"
            log_info "You can manually run: brew bundle install --file=$brewfile"
        fi
    else
        log_info "Skipped Brewfile installation"
        log_info "You can manually run: brew bundle install --file=$brewfile"
    fi

    return 0
}
