# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modular, plugin-based macOS dotfiles system with automatic dependency resolution. Designed for Bash 3.2+ compatibility (macOS default).

## Common Commands

```bash
# Run full bootstrap
./bootstrap.sh

# Dry run (preview without changes)
./bootstrap.sh --dry-run

# Run specific plugin with dependencies
./run-plugin.sh brewfile

# Run specific plugin only (skip dependencies)
./run-plugin.sh dotfiles --only

# List all plugins
./bootstrap.sh --list

# Debug mode
./bootstrap.sh --debug
```

## Architecture

### Bootstrap Plugin System

The bootstrap system uses a plugin architecture with automatic dependency resolution via topological sort (DFS).

**Plugin execution order**: `xcode → homebrew → zsh → ohmyzsh → dotfiles` (brewfile runs parallel after homebrew)

**Plugin structure** (`bootstrap.d/plugins/XX-name.sh`):
```bash
PLUGIN_NAME="name"
PLUGIN_DEPENDS="dependency1 dependency2"
PLUGIN_DESCRIPTION="What this plugin does"

plugin_name_main() {
    # Implementation
}
```

**Core libraries**:
- `bootstrap.d/lib/utils.sh` - Logging (`log_info`, `log_success`, `log_error`), system checks, file operations
- `bootstrap.d/lib/plugin_system.sh` - Plugin loading, dependency resolution, execution engine

### Configuration Structure

**Zsh configuration** uses a modular `dot` command pattern:
- `zsh/.zshrc` - Main config, loads Oh My Zsh and sources modules via `dot zsh.d/<module>.zsh`
- `zsh/.zshrc.dot.zsh` - Implements `dotfiles::get_root()` and `dot` command for relative path sourcing
- `zsh.d/*.zsh` - Individual tool configurations (fzf, zoxide, starship, etc.)

**Brewfile** uses Ruby's `instance_eval` for modular includes:
- `brew/Brewfile` - Main file, imports from `brew.d/`
- `brew/brew.d/*.Brewfile` - Categorized packages (shell-terminal, database, devops, etc.)
- `brew/Brewfile.local` - Machine-specific packages (gitignored)

### Key Design Patterns

1. **Bash 3.2 compatibility** - No associative arrays; uses parallel indexed arrays
2. **Idempotent operations** - Safe to run multiple times
3. **Local overrides** - `*.local` files are gitignored for machine-specific configs

## Important Constraints

- All git commits must be in English and must NOT contain "claude" or "Co-Authored-By"
- Do not use `git commit --amend`; always create new commits
- Do not generate README/documentation files unless explicitly requested
- Respond to user in Chinese
