#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
#  Plugin System with Dependency Resolution
#  (Compatible with Bash 3.2+ — no associative arrays)
# ────────────────────────────────────────────────────────────────

# Prevent multiple sourcing
[[ -n "${BOOTSTRAP_PLUGIN_SYSTEM_LOADED:-}" ]] && return 0
readonly BOOTSTRAP_PLUGIN_SYSTEM_LOADED=1

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Plugin registry (parallel indexed arrays — index i maps across all four)
PLUGIN_NAMES=()            # plugin name
PLUGIN_PATHS=()            # plugin file path
PLUGIN_DEPS=()             # space-separated dependency names
PLUGIN_DESCS=()            # human-readable description
PLUGIN_EXECUTION_ORDER=()  # resolved execution order

# Internal resolution state
_PLUGIN_EXECUTED=()        # names already visited
_PLUGIN_EXECUTING=()       # names in current DFS path (cycle detection)

# ── Internal helpers ──────────────────────────────────────────

# Find a plugin's index by name. Sets _PLUGIN_IDX on success.
_plugin_find() {
    local name="$1"
    for (( _PLUGIN_IDX = 0; _PLUGIN_IDX < ${#PLUGIN_NAMES[@]}; _PLUGIN_IDX++ )); do
        [[ "${PLUGIN_NAMES[$_PLUGIN_IDX]}" == "$name" ]] && return 0
    done
    return 1
}

_plugin_exists() { _plugin_find "$1"; }

_plugin_path() { _plugin_find "$1" && echo "${PLUGIN_PATHS[$_PLUGIN_IDX]}"; }
_plugin_deps() { _plugin_find "$1" && echo "${PLUGIN_DEPS[$_PLUGIN_IDX]}"; }
_plugin_desc() { _plugin_find "$1" && echo "${PLUGIN_DESCS[$_PLUGIN_IDX]}"; }

# Check if a value is present in the given arguments
_in_list() {
    local value="$1"; shift
    local item
    for item in "$@"; do
        [[ "$item" == "$value" ]] && return 0
    done
    return 1
}

_is_executed() {
    [[ ${#_PLUGIN_EXECUTED[@]} -gt 0 ]] || return 1
    _in_list "$1" "${_PLUGIN_EXECUTED[@]}"
}

_is_executing() {
    [[ ${#_PLUGIN_EXECUTING[@]} -gt 0 ]] || return 1
    _in_list "$1" "${_PLUGIN_EXECUTING[@]}"
}

_remove_executing() {
    local name="$1" i
    local tmp=()
    for (( i = 0; i < ${#_PLUGIN_EXECUTING[@]}; i++ )); do
        [[ "${_PLUGIN_EXECUTING[$i]}" != "$name" ]] && tmp+=("${_PLUGIN_EXECUTING[$i]}")
    done
    _PLUGIN_EXECUTING=()
    [[ ${#tmp[@]} -gt 0 ]] && _PLUGIN_EXECUTING=("${tmp[@]}")
    return 0
}

# Reset dependency-resolution state
reset_plugin_state() {
    PLUGIN_EXECUTION_ORDER=()
    _PLUGIN_EXECUTED=()
    _PLUGIN_EXECUTING=()
}

# ── Public API ────────────────────────────────────────────────

# Register a plugin
# Usage: register_plugin <plugin_path>
register_plugin() {
    local plugin_path="$1"

    if [[ ! -f "$plugin_path" ]]; then
        log_error "Plugin file not found: $plugin_path"
        return 1
    fi

    # Extract metadata from plugin file (use || true to handle empty results)
    local plugin_name plugin_depends plugin_description
    plugin_name=$(grep -E "^PLUGIN_NAME=" "$plugin_path" | head -1 | cut -d'=' -f2- | tr -d '"' | tr -d "'" || true)
    plugin_depends=$(grep -E "^PLUGIN_DEPENDS=" "$plugin_path" | head -1 | cut -d'=' -f2- | tr -d '"' | tr -d "'" || true)
    plugin_description=$(grep -E "^PLUGIN_DESCRIPTION=" "$plugin_path" | head -1 | cut -d'=' -f2- | tr -d '"' | tr -d "'" || true)

    if [[ -z "$plugin_name" ]]; then
        log_error "Plugin name not defined in: $plugin_path"
        return 1
    fi

    PLUGIN_NAMES+=("$plugin_name")
    PLUGIN_PATHS+=("$plugin_path")
    PLUGIN_DEPS+=("${plugin_depends:-}")
    PLUGIN_DESCS+=("${plugin_description:-No description}")

    log_debug "Registered plugin: $plugin_name (depends on: ${plugin_depends:-none})"
}

# Load all plugins from directory
# Usage: load_plugins <plugins_directory>
load_plugins() {
    local plugins_dir="$1"

    if [[ ! -d "$plugins_dir" ]]; then
        log_error "Plugins directory not found: $plugins_dir"
        return 1
    fi

    log_info "Loading plugins from: $plugins_dir"

    # Temporarily disable exit on error for plugin loading
    set +e

    local plugin_count=0
    local plugin_file

    # Use glob with nullglob
    shopt -s nullglob
    local -a plugin_files=("$plugins_dir"/*.sh)
    shopt -u nullglob

    # Simple bubble sort (avoid subshell issues)
    local n=${#plugin_files[@]}
    if (( n > 1 )); then
        local i j temp
        for ((i = 0; i < n-1; i++)); do
            for ((j = 0; j < n-i-1; j++)); do
                if [[ "${plugin_files[j]}" > "${plugin_files[j+1]}" ]]; then
                    temp="${plugin_files[j]}"
                    plugin_files[j]="${plugin_files[j+1]}"
                    plugin_files[j+1]="$temp"
                fi
            done
        done
    fi

    # Register each plugin
    log_debug "Found ${#plugin_files[@]} plugin files"
    if [[ ${#plugin_files[@]} -gt 0 ]]; then
        for plugin_file in "${plugin_files[@]}"; do
            log_debug "Registering: $plugin_file"
            register_plugin "$plugin_file" || log_warning "Failed to register: $plugin_file"
            plugin_count=$((plugin_count + 1))
        done
    fi
    log_debug "Registration complete"

    # Re-enable exit on error
    set -e

    log_success "Loaded $plugin_count plugins"
}

# Resolve dependencies using topological sort (DFS)
# Usage: resolve_dependencies
resolve_dependencies() {
    log_info "Resolving plugin dependencies..."

    reset_plugin_state

    if [[ ${#PLUGIN_NAMES[@]} -eq 0 ]]; then
        log_warning "No plugins registered"
        return 0
    fi

    local plugin_name
    for plugin_name in "${PLUGIN_NAMES[@]}"; do
        if ! _is_executed "$plugin_name"; then
            visit_plugin "$plugin_name" || return 1
        fi
    done

    log_success "Dependency resolution complete. Execution order: ${PLUGIN_EXECUTION_ORDER[*]}"
}

# Visit plugin for topological sort (recursive DFS)
# Usage: visit_plugin <plugin_name>
visit_plugin() {
    local plugin_name="$1"

    # Cycle detection
    if _is_executing "$plugin_name"; then
        log_error "Circular dependency detected involving plugin: $plugin_name"
        return 1
    fi

    # Already visited
    if _is_executed "$plugin_name"; then
        return 0
    fi

    # Check if plugin exists
    if ! _plugin_exists "$plugin_name"; then
        log_error "Plugin not found: $plugin_name"
        return 1
    fi

    # Mark as currently executing
    _PLUGIN_EXECUTING+=("$plugin_name")

    # Visit dependencies first
    local dependencies
    dependencies="$(_plugin_deps "$plugin_name")"
    if [[ -n "$dependencies" ]]; then
        log_debug "Processing dependencies for $plugin_name: $dependencies"
        local dep
        for dep in $dependencies; do
            visit_plugin "$dep" || return 1
        done
    fi

    # Mark as executed and add to execution order
    _remove_executing "$plugin_name"
    _PLUGIN_EXECUTED+=("$plugin_name")
    PLUGIN_EXECUTION_ORDER+=("$plugin_name")

    log_debug "Added to execution order: $plugin_name"
}

# Execute a single plugin
# Usage: execute_plugin <plugin_name>
execute_plugin() {
    local plugin_name="$1"

    if ! _plugin_exists "$plugin_name"; then
        log_error "Plugin not registered: $plugin_name"
        return 1
    fi

    local plugin_path
    plugin_path="$(_plugin_path "$plugin_name")"

    log_step "Executing plugin: $plugin_name"
    log_info "  Description: $(_plugin_desc "$plugin_name")"

    # Source and execute the plugin
    # shellcheck source=/dev/null
    if source "$plugin_path"; then
        # Call the main function (convention: plugin_<name>_main)
        local main_function="plugin_${plugin_name}_main"
        if declare -F "$main_function" >/dev/null; then
            if $main_function; then
                log_success "Plugin completed: $plugin_name"
                return 0
            else
                log_error "Plugin failed: $plugin_name"
                return 1
            fi
        else
            log_error "Main function not found: $main_function"
            return 1
        fi
    else
        log_error "Failed to source plugin: $plugin_name"
        return 1
    fi
}

# Execute all plugins in dependency order
# Usage: execute_plugins [--dry-run]
execute_plugins() {
    local dry_run=false

    if [[ "${1:-}" == "--dry-run" ]]; then
        dry_run=true
        log_info "DRY RUN MODE - No plugins will be executed"
    fi

    if [[ ${#PLUGIN_EXECUTION_ORDER[@]} -eq 0 ]]; then
        log_warning "No plugins to execute"
        return 0
    fi

    log_step "Execution order: ${PLUGIN_EXECUTION_ORDER[*]}"
    echo

    local failed_plugins=()

    for plugin_name in "${PLUGIN_EXECUTION_ORDER[@]}"; do
        if $dry_run; then
            log_info "[DRY RUN] Would execute: $plugin_name - $(_plugin_desc "$plugin_name")"
        else
            if ! execute_plugin "$plugin_name"; then
                failed_plugins+=("$plugin_name")
                if [[ "${BOOTSTRAP_CONTINUE_ON_ERROR:-false}" != "true" ]]; then
                    log_error "Stopping execution due to plugin failure: $plugin_name"
                    return 1
                else
                    log_warning "Continuing despite failure in: $plugin_name"
                fi
            fi
        fi
        echo
    done

    if [[ ${#failed_plugins[@]} -gt 0 ]]; then
        log_error "Failed plugins: ${failed_plugins[*]}"
        return 1
    fi

    log_success "All plugins executed successfully"
}

# List all registered plugins
# Usage: list_plugins
list_plugins() {
    log_info "Registered plugins:"
    echo

    if [[ ${#PLUGIN_NAMES[@]} -eq 0 ]]; then
        echo "  (none)"
        return 0
    fi

    local plugin_name deps desc
    for plugin_name in "${PLUGIN_NAMES[@]}"; do
        deps="$(_plugin_deps "$plugin_name")"
        desc="$(_plugin_desc "$plugin_name")"
        [[ -z "$deps" ]] && deps="none"
        echo "  • $plugin_name"
        echo "    Description: $desc"
        echo "    Dependencies: $deps"
        echo
    done
}
