# OOG Environment Setup

A modular and flexible environment setup script for macOS and Linux systems. This script helps you quickly set up your development environment with your preferred configurations, aliases, and tools.

## Features

- **Modular Configuration**: Each component (aliases, shell configs, vim configs, etc.) is in its own file
- **Cross-Platform**: Works on both macOS and Linux systems
- **Safe Installation**: Creates backups before making changes
- **Easy Management**: Add, remove, or list configurations easily
- **Version Control Ready**: Easy to maintain in git and share across machines

## Directory Structure

```
.
├── oog_init.sh
└── config/
    ├── aliases/
    │   └── common_aliases.sh
    ├── shell/
    │   └── bash_config.sh
    ├── vim/
    │   └── vim_config.vim
    └── git/
        └── git_config
```

## Prerequisites

- Bash shell
- Git
- Internet connection (for package installation)

## Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd <repo-directory>
   ```

2. Make the script executable:
   ```bash
   chmod +x oog_init.sh
   ```

3. Run the setup script:
   ```bash
   ./oog_init.sh
   ```

## Usage

### Basic Commands

- **Setup Environment**:
  ```bash
  ./oog_init.sh
  ```

- **List Current Configurations**:
  ```bash
  ./oog_init.sh list
  ```

- **Remove a Configuration**:
  ```bash
  ./oog_init.sh remove <config_file> <target_file>
  ```

- **Revert to Previous State**:
  ```bash
  ./oog_init.sh revert
  ```

### Configuration Files

1. **Aliases** (`config/aliases/common_aliases.sh`):
   - Common command shortcuts
   - Git aliases
   - Directory navigation
   - Editor shortcuts
   - System shortcuts

2. **Shell Configuration** (`config/shell/bash_config.sh`):
   - History settings
   - Prompt customization
   - Environment variables
   - Path configurations
   - Language-specific settings

3. **Vim Configuration** (`config/vim/vim_config.vim`):
   - Basic editor settings
   - Plugin management (vim-plug)
   - Key mappings
   - Color schemes
   - Language support

4. **Git Configuration** (`config/git/git_config`):
   - Core settings
   - Aliases
   - Color settings
   - URL shortcuts
   - Merge settings

## Customization

### Adding New Configurations

1. Create a new file in the appropriate directory under `config/`
2. Add your configuration
3. Update the main script's setup function to include your new configuration

### Modifying Existing Configurations

1. Edit the relevant file in the `config/` directory
2. Run the setup script again to apply changes

### Local Overrides

You can create local override files that won't be tracked in git:
- `~/.bashrc.local`
- `~/.vimrc.local`
- `~/.gitconfig.local`

These files will be sourced after the main configurations.

## Backup System

The script creates backups in `~/.dotfiles_backup/` with timestamps before making any changes. You can revert to a previous state using:

```bash
./oog_init.sh revert
```

## Package Installation

The script automatically installs required packages:
- **macOS**: Uses Homebrew
- **Linux**: Uses apt (Debian/Ubuntu) or yum (RedHat/CentOS)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[Your chosen license]

## Author

[Your name]

## Acknowledgments

- Inspired by various dotfiles repositories
- Thanks to the open-source community for tools and plugins 