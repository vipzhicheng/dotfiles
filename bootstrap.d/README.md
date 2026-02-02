# Bootstrap System

A modular, plugin-based bootstrap system for setting up macOS machines.

## Architecture

### Directory Structure

```
bootstrap.d/
├── lib/
│   ├── utils.sh           # Utility functions (logging, file operations, etc.)
│   └── plugin_system.sh   # Plugin loader and dependency resolver
└── plugins/
    ├── 01-xcode.sh        # Xcode Command Line Tools
    ├── 02-homebrew.sh     # Homebrew package manager
    ├── 03-zsh.sh          # Zsh shell
    ├── 04-ohmyzsh.sh      # Oh My Zsh framework
    ├── 05-brewfile.sh     # Install packages from Brewfile
    └── 06-dotfiles.sh     # Create dotfiles symlinks
```

### Plugin System

Each plugin is a self-contained bash script with:

1. **Metadata** (required):
   - `PLUGIN_NAME`: Unique identifier
   - `PLUGIN_DEPENDS`: Space-separated list of plugin dependencies
   - `PLUGIN_DESCRIPTION`: Human-readable description

2. **Main Function** (required):
   - `plugin_<name>_main`: Entry point for the plugin

### Example Plugin

```bash
#!/usr/bin/env bash

PLUGIN_NAME="example"
PLUGIN_DEPENDS="homebrew zsh"
PLUGIN_DESCRIPTION="Example plugin that depends on homebrew and zsh"

plugin_example_main() {
    log_step "Running example plugin"
    
    # Check if something is installed
    if command_exists some_command; then
        log_success "Already installed"
        return 0
    fi
    
    # Install something
    log_info "Installing..."
    brew install some_package
    
    log_success "Installation complete"
    return 0
}
```

## Features

### 1. Dependency Resolution

The plugin system automatically:
- Resolves dependencies using topological sort
- Detects circular dependencies
- Executes plugins in the correct order
- Validates all dependencies exist before execution

### 2. Idempotency

All plugins are designed to be idempotent:
- Safe to run multiple times
- Check if already installed/configured
- Skip unnecessary operations
- No destructive operations without confirmation

### 3. Error Handling

- Each plugin returns proper exit codes
- Failed plugins can stop or continue execution (configurable)
- Comprehensive error messages
- Pre-flight checks before execution

### 4. Dry Run Mode

Test the bootstrap process without making changes:
```bash
./bootstrap.sh --dry-run
```

### 5. Debug Mode

Enable detailed logging:
```bash
./bootstrap.sh --debug
```

## Creating New Plugins

1. Create a new file in `bootstrap.d/plugins/`:
   ```bash
   touch bootstrap.d/plugins/XX-myplugin.sh
   chmod +x bootstrap.d/plugins/XX-myplugin.sh
   ```

2. Add plugin metadata:
   ```bash
   PLUGIN_NAME="myplugin"
   PLUGIN_DEPENDS="homebrew"  # or empty string for no deps
   PLUGIN_DESCRIPTION="What this plugin does"
   ```

3. Implement the main function:
   ```bash
   plugin_myplugin_main() {
       log_step "Setting up myplugin"
       
       # Your logic here
       
       return 0  # or 1 on error
   }
   ```

4. Use utility functions from `lib/utils.sh`:
   - `log_info`, `log_success`, `log_warning`, `log_error`
   - `command_exists <command>`
   - `ask_confirmation <prompt> [y/n]`
   - `backup_file <file>`
   - `safe_symlink <source> <target>`

## Best Practices

1. **Check before install**: Always check if something is already installed
2. **Be specific**: Log what you're doing and why
3. **Handle errors**: Return proper exit codes
4. **Be safe**: Backup before modifying files
5. **Be quiet**: Only show important information (use debug mode for details)
6. **Be fast**: Cache checks, avoid redundant operations
7. **Be helpful**: Provide instructions when manual intervention is needed

## Execution Flow

```
1. Pre-flight checks (OS, permissions, directories)
2. Load all plugins from plugins directory
3. Register plugins and extract metadata
4. Resolve dependencies (topological sort)
5. Display execution plan
6. Ask for confirmation (unless --skip-confirmation)
7. Execute plugins in dependency order
8. Report results
```

## Usage Examples

```bash
# Normal run with confirmations
./bootstrap.sh

# Dry run to see what would happen
./bootstrap.sh --dry-run

# List all plugins and their dependencies
./bootstrap.sh --list

# Run with debug output
./bootstrap.sh --debug

# Fully automated (no prompts)
./bootstrap.sh --skip-confirmation

# Continue even if some plugins fail
./bootstrap.sh --continue-on-error
```

## Adding to .gitignore

Add temporary/local files that shouldn't be committed:
```gitignore
# Bootstrap temporary files
bootstrap.d/plugins/*.local.sh
bootstrap.d/.state/
```
