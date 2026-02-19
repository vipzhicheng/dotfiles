# ────────────────────────────────────────────────────────────────
#  Dotfiles introspection utility functions
# ────────────────────────────────────────────────────────────────

# Debug helper function
function dotfiles::debug() {
    [[ "${DOTFILES_DEBUG:-}" == "true" ]] && print -u2 -- "[dotfiles debug] $*"
}

# Returns the root directory of the dotfiles repository (regardless of where .zshrc is symlinked)
# Computed only once and cached in the variable DOTFILES_ROOT
typeset -g DOTFILES_ROOT

function dotfiles::get_root() {
    if [[ -n "${DOTFILES_ROOT:-}" ]]; then
        dotfiles::debug "Cache hit: DOTFILES_ROOT=$DOTFILES_ROOT"
        print -r -- "$DOTFILES_ROOT"
        return 0
    fi

    dotfiles::debug "Cache miss, computing DOTFILES_ROOT..."

    # %x = path of the currently sourced file, :A → resolve symlink and get absolute path
    local this_file="${(%):-%x:A}"
    dotfiles::debug "Current file: $this_file"

    # Assuming structure dotfiles/zsh/.zshrc.dot.zsh → go up two levels to reach root
    local possible_root="${this_file:A:h:h}"
    dotfiles::debug "Possible root: $possible_root"

    # Basic validation: check for signature files/directories in the supposed root
    # (Adjust the conditions according to your actual repository structure)
    if [[ -d "$possible_root" && ( -f "$possible_root/Brewfile" || -d "$possible_root/config" || -f "$possible_root/zsh/.zshrc.local.example" ) ]]; then
        DOTFILES_ROOT="$possible_root"
        dotfiles::debug "Validation passed, using: $DOTFILES_ROOT"
    else
        # Fallback if detection fails (you can adjust this fallback logic if needed)
        dotfiles::debug "Validation failed, using fallback"
        print -u2 -- "Warning: Could not reliably determine dotfiles root directory, using assumed path"
        DOTFILES_ROOT="${this_file:A:h:h}"
        print -u2 -- "Using fallback path: $DOTFILES_ROOT"
    fi

    print -r -- "$DOTFILES_ROOT"
}

# Convenience function: source a file using a path relative to the dotfiles root
# Usage examples:
#   dot zsh/aliases.zsh
#   dot config/starship/starship.toml   # Note: .toml files are usually not sourced but evaluated
function dot() {
    local subpath="$1"
    shift

    dotfiles::debug "dot() called with: $subpath"

    # Call dotfiles::get_root to ensure DOTFILES_ROOT is set (first call will cache it)
    dotfiles::get_root > /dev/null || return 1

    local target="$DOTFILES_ROOT/$subpath"
    dotfiles::debug "Target file: $target"

    if [[ ! -f "$target" && ! -d "$target" ]]; then
        print -u2 -- "Error: File does not exist → $target"
        return 1
    fi

    dotfiles::debug "Sourcing: $target"
    builtin source "$target" "$@"
    dotfiles::debug "Sourced successfully: $target"
}
