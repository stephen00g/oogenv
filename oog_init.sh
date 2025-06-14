#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration directory
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/debian_version ]]; then
        OS="debian"
    elif [[ -f /etc/redhat-release ]]; then
        OS="redhat"
    else
        OS="unknown"
    fi
    print_status "Detected OS: $OS"
}

# Backup existing configurations
backup_configs() {
    local backup_path="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_path"
    
    # Backup files
    local files_to_backup=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zshrc"
        "$HOME/.vimrc"
        "$HOME/.config/nvim"
        "$HOME/.gitconfig"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [ -e "$file" ]; then
            print_status "Backing up $file"
            cp -r "$file" "$backup_path/"
        fi
    done
}

# Install required packages
install_packages() {
    print_status "Installing required packages..."
    
    if [ "$OS" = "macos" ]; then
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Install packages using Homebrew
        brew install git vim neovim zsh curl wget
    elif [ "$OS" = "debian" ]; then
        sudo apt update
        sudo apt install -y git vim neovim zsh curl wget
    elif [ "$OS" = "redhat" ]; then
        sudo yum update
        sudo yum install -y git vim neovim zsh curl wget
    fi
}

# Function to check if a config is already included
is_config_included() {
    local config_file="$1"
    local target_file="$2"
    local include_pattern="# Include $config_file"
    
    if [ -f "$target_file" ]; then
        grep -q "$include_pattern" "$target_file"
        return $?
    fi
    return 1
}

# Function to add config include
add_config_include() {
    local config_file="$1"
    local target_file="$2"
    local include_pattern="# Include $config_file"
    
    if ! is_config_included "$config_file" "$target_file"; then
        echo -e "\n$include_pattern" >> "$target_file"
        echo "source $config_file" >> "$target_file"
        print_status "Added $config_file to $target_file"
    else
        print_warning "$config_file is already included in $target_file"
    fi
}

# Setup shell configurations
setup_shell_configs() {
    print_status "Setting up shell configurations..."
    
    # Setup bash
    if [ -f "$HOME/.bashrc" ]; then
        add_config_include "$CONFIG_DIR/shell/bash_config.sh" "$HOME/.bashrc"
    fi
    
    # Setup zsh
    if [ -f "$HOME/.zshrc" ]; then
        add_config_include "$CONFIG_DIR/shell/zsh_config.sh" "$HOME/.zshrc"
    fi
    
    # Setup aliases
    add_config_include "$CONFIG_DIR/aliases/common_aliases.sh" "$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ]; then
        add_config_include "$CONFIG_DIR/aliases/common_aliases.sh" "$HOME/.zshrc"
    fi
}

# Function to install vim plugins
install_vim_plugins() {
    print_status "Installing vim plugins..."
    
    # Install vim plugins
    if command -v vim &> /dev/null; then
        print_status "Installing vim plugins..."
        vim +'PlugInstall --sync' +qa
    fi
    
    # Install neovim plugins
    if command -v nvim &> /dev/null; then
        print_status "Installing neovim plugins..."
        nvim +'PlugInstall --sync' +qa
    fi
}

# Function to setup vim configurations
setup_vim_configs() {
    print_status "Setting up vim configurations..."
    
    # Create vim config directory if it doesn't exist
    mkdir -p "$HOME/.vim"
    
    # Create neovim config directory if it doesn't exist
    mkdir -p "$HOME/.config/nvim"
    
    # Install vim-plug if not already installed
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        print_status "Installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Install vim-plug for neovim if not already installed
    if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
        print_status "Installing vim-plug for neovim..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Create undo directory for neovim
    mkdir -p "$HOME/.config/nvim/undodir"
    
    # Check if .vimrc exists
    if [ -f "$HOME/.vimrc" ]; then
        # Add include line if it doesn't exist
        if ! grep -q "source $CONFIG_DIR/vim/vim_config.vim" "$HOME/.vimrc"; then
            echo "source $CONFIG_DIR/vim/vim_config.vim" >> "$HOME/.vimrc"
        fi
    else
        # Create .vimrc with include
        echo "source $CONFIG_DIR/vim/vim_config.vim" > "$HOME/.vimrc"
    fi
    
    # Check if init.vim exists
    if [ -f "$HOME/.config/nvim/init.vim" ]; then
        # Remove any existing include lines
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' '/source.*nvim_config.vim/d' "$HOME/.config/nvim/init.vim"
        else
            # Linux
            sed -i '/source.*nvim_config.vim/d' "$HOME/.config/nvim/init.vim"
        fi
        # Add include line
        echo "source $CONFIG_DIR/vim/nvim_config.vim" >> "$HOME/.config/nvim/init.vim"
    else
        # Create init.vim with include
        echo "source $CONFIG_DIR/vim/nvim_config.vim" > "$HOME/.config/nvim/init.vim"
    fi
    
    # Install plugins automatically
    install_vim_plugins
    
    print_status "Vim configurations setup complete!"
}

# Setup git configurations
setup_git_configs() {
    print_status "Setting up git configurations..."
    
    if [ -f "$HOME/.gitconfig" ]; then
        add_config_include "$CONFIG_DIR/git/git_config" "$HOME/.gitconfig"
    fi
}

# Function to list all included configs
list_configs() {
    print_status "Currently included configurations:"
    
    # Check bash configs
    if [ -f "$HOME/.bashrc" ]; then
        echo -e "\nBash configurations:"
        grep "# Include" "$HOME/.bashrc" | sed 's/# Include //'
    fi
    
    # Check zsh configs
    if [ -f "$HOME/.zshrc" ]; then
        echo -e "\nZsh configurations:"
        grep "# Include" "$HOME/.zshrc" | sed 's/# Include //'
    fi
    
    # Check vim configs
    if [ -f "$HOME/.vimrc" ]; then
        echo -e "\nVim configurations:"
        grep "# Include" "$HOME/.vimrc" | sed 's/# Include //'
    fi
    
    # Check nvim configs
    if [ -f "$HOME/.config/nvim/init.vim" ]; then
        echo -e "\nNeovim configurations:"
        grep "# Include" "$HOME/.config/nvim/init.vim" | sed 's/# Include //'
    fi
    
    # Check git configs
    if [ -f "$HOME/.gitconfig" ]; then
        echo -e "\nGit configurations:"
        grep "# Include" "$HOME/.gitconfig" | sed 's/# Include //'
    fi
}

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  list           List current configurations"
    echo "  backups        List available backups"
    echo "  revert         Revert to a backup"
    echo
    echo "Examples:"
    echo "  $0                    # Run the full setup"
    echo "  $0 list              # List current configurations"
    echo "  $0 backups           # List available backups"
    echo "  $0 revert            # Revert to a backup"
    echo
    echo "Configuration Files:"
    echo "  - Aliases:      $CONFIG_DIR/aliases/common_aliases.sh"
    echo "  - Shell:        $CONFIG_DIR/shell/bash_config.sh"
    echo "  - Vim:          $CONFIG_DIR/vim/vim_config.vim"
    echo "  - Neovim:       $CONFIG_DIR/vim/nvim_config.vim"
    echo "  - Git:          $CONFIG_DIR/git/git_config"
}

# Function to list backup states
list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backup directory found!"
        exit 1
    fi

    print_status "Available backups:"
    echo
    echo "No. | Timestamp              | Files"
    echo "----|----------------------|------------------"
    
    local i=1
    while IFS= read -r backup; do
        # Convert timestamp format (works on both Linux and macOS)
        timestamp=$(echo "$backup" | tr '_' ' ')
        printf "%-3d | %-20s | " "$i" "$timestamp"
        if [ -d "$BACKUP_DIR/$backup" ]; then
            ls "$BACKUP_DIR/$backup" | tr '\n' ' '
        fi
        echo
        ((i++))
    done < <(ls -t "$BACKUP_DIR")
}

# Function to select a backup interactively
select_backup() {
    local -a timestamps
    local i=1
    
    # Get list of backups
    while IFS= read -r backup; do
        # Convert timestamp format (works on both Linux and macOS)
        timestamp=$(echo "$backup" | tr '_' ' ')
        timestamps+=("$timestamp")
        ((i++))
    done < <(ls -t "$BACKUP_DIR")
    
    if [ ${#timestamps[@]} -eq 0 ]; then
        print_error "No backups available!"
        exit 1
    fi
    
    echo
    print_status "Select a backup to restore:"
    select timestamp in "${timestamps[@]}"; do
        if [ -n "$timestamp" ]; then
            # Convert space to underscore for the directory name
            echo "${timestamp// /_}"
            return 0
        else
            print_error "Invalid selection. Please try again."
        fi
    done
}

# Function to revert changes
revert() {
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backup directory found!"
        exit 1
    fi
    
    local backup_to_restore
    
    # If a specific backup is provided, use it
    if [ ! -z "$2" ]; then
        backup_to_restore="$2"
        if [ ! -d "$BACKUP_DIR/$backup_to_restore" ]; then
            print_error "Backup '$backup_to_restore' not found!"
            echo
            list_backups
            exit 1
        fi
    else
        # Show interactive menu to select backup
        backup_to_restore=$(select_backup)
        if [ -z "$backup_to_restore" ]; then
            print_status "Restore cancelled"
            exit 1
        fi
    fi
    
    print_status "Restoring backup: $backup_to_restore"
    print_warning "This will overwrite your current configurations!"
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        exit 1
    fi
    
    # Restore files
    if [ -d "$BACKUP_DIR/$backup_to_restore" ]; then
        cp -r "$BACKUP_DIR/$backup_to_restore/"* "$HOME/"
        print_status "Restore completed successfully!"
        print_status "Please restart your terminal to apply changes"
    else
        print_error "Backup directory not found: $BACKUP_DIR/$backup_to_restore"
        exit 1
    fi
}

# Main function
main() {
    print_status "Starting environment setup..."
    
    # Detect OS
    detect_os
    
    # Backup existing configurations
    backup_configs
    
    # Install required packages
    install_packages
    
    # Setup configurations
    setup_shell_configs
    setup_vim_configs
    setup_git_configs
    
    print_status "Setup completed successfully!"
    print_status "Please restart your terminal or run 'source ~/.bashrc' (or 'source ~/.zshrc' for zsh) to apply changes"
}

# Parse command line arguments
case "$1" in
    "-h"|"--help")
        show_help
        ;;
    "revert")
        revert "$@"
        ;;
    "backups")
        list_backups
        ;;
    "list")
        list_configs
        ;;
    *)
        main
        ;;
esac 