#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin: Xcode Command Line Tools
# ────────────────────────────────────────────────────────────────

PLUGIN_NAME="xcode"
PLUGIN_DEPENDS=""
PLUGIN_DESCRIPTION="Install Xcode Command Line Tools (required for development)"

plugin_xcode_main() {
    log_step "Installing Xcode Command Line Tools"

    # Check if already installed
    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools already installed at: $(xcode-select -p)"
        return 0
    fi

    log_info "Xcode Command Line Tools not found, installing..."

    # Create a temporary file to trigger installation
    local tmp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    touch "$tmp_file"

    # Find the latest Xcode CLI tools
    local cmd_line_tools
    cmd_line_tools=$(softwareupdate -l 2>/dev/null |
        grep "\*.*Command Line Tools" |
        tail -n 1 |
        sed 's/^[^C]* //')

    if [[ -z "$cmd_line_tools" ]]; then
        # Alternative method: direct installation
        log_info "Installing via xcode-select..."
        if xcode-select --install 2>/dev/null; then
            log_info "Please complete the installation in the GUI dialog"
            log_info "Waiting for installation to complete..."

            # Wait for installation
            until xcode-select -p &>/dev/null; do
                sleep 5
            done

            log_success "Xcode Command Line Tools installed"
        else
            log_error "Failed to trigger Xcode Command Line Tools installation"
            return 1
        fi
    else
        # Install via softwareupdate
        log_info "Installing: $cmd_line_tools"
        sudo softwareupdate -i "$cmd_line_tools" --verbose
    fi

    # Clean up
    rm -f "$tmp_file"

    # Verify installation
    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools successfully installed"
        return 0
    else
        log_error "Xcode Command Line Tools installation failed"
        return 1
    fi
}
