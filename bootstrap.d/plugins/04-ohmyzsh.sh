#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Oh My Zsh
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="ohmyzsh"
PLUGIN_DEPENDS="zsh"
PLUGIN_DESCRIPTION="Install Oh My Zsh framework"

plugin_ohmyzsh_main() {
    log_step "Installing Oh My Zsh"

    local oh_my_zsh_dir="${HOME}/.oh-my-zsh"

    # Check if already installed
    if [[ -d "$oh_my_zsh_dir" ]]; then
        log_success "Oh My Zsh already installed at: $oh_my_zsh_dir"

        # Update Oh My Zsh
        log_info "Updating Oh My Zsh..."
        if [[ -f "$oh_my_zsh_dir/tools/upgrade.sh" ]]; then
            env ZSH="$oh_my_zsh_dir" sh "$oh_my_zsh_dir/tools/upgrade.sh"
        fi

        return 0
    fi

    log_info "Oh My Zsh not found, installing..."

    # Backup existing .zshrc if exists
    if [[ -f "${HOME}/.zshrc" ]]; then
        backup_file "${HOME}/.zshrc"
    fi

    # Install Oh My Zsh (unattended mode)
    local install_script="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

    if sh -c "$(curl -fsSL $install_script)" "" --unattended; then
        log_success "Oh My Zsh installed successfully"
    else
        log_error "Oh My Zsh installation failed"
        return 1
    fi

    # Install popular plugins
    log_info "Installing Oh My Zsh plugins..."

    local custom_plugins_dir="${oh_my_zsh_dir}/custom/plugins"

    # zsh-autosuggestions
    if [[ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$custom_plugins_dir/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            "$custom_plugins_dir/zsh-syntax-highlighting"
    fi

    log_success "Oh My Zsh plugins installed"

    return 0
}
