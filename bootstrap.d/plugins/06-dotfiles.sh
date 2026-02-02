#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Dotfiles Symlinks
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="dotfiles"
PLUGIN_DEPENDS="ohmyzsh"
PLUGIN_DESCRIPTION="Create symlinks for dotfiles"

plugin_dotfiles_main() {
    log_step "Setting up dotfiles symlinks"

    # Get dotfiles root directory
    local dotfiles_root
    dotfiles_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    log_info "Dotfiles root: $dotfiles_root"

    # Backup and symlink .zshrc
    if [[ -f "$dotfiles_root/zsh/.zshrc" ]]; then
        log_info "Creating symlink for .zshrc"
        safe_symlink "$dotfiles_root/zsh/.zshrc" "${HOME}/.zshrc"
        log_success "Symlinked: ~/.zshrc -> $dotfiles_root/zsh/.zshrc"
    else
        log_warning ".zshrc not found in dotfiles"
    fi

    # Create .zshrc.local if it doesn't exist
    local zshrc_local="${HOME}/.zshrc.local"
    if [[ ! -f "$zshrc_local" ]]; then
        log_info "Creating empty .zshrc.local for local customizations"
        touch "$zshrc_local"
        log_success "Created: $zshrc_local"
    fi

    # Create .zshrc.temp if it doesn't exist in dotfiles
    local zshrc_temp="$dotfiles_root/zsh/.zshrc.temp"
    if [[ ! -f "$zshrc_temp" ]]; then
        log_info "Creating empty .zshrc.temp for temporary configurations"
        touch "$zshrc_temp"
        log_success "Created: $zshrc_temp"
    fi

    # Symlink other dotfiles as needed
    # Add more symlink operations here for other config files

    log_success "Dotfiles symlinks created"

    return 0
}
