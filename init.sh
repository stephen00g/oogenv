
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

# Setup vim/nvim configurations
setup_vim_configs() {
    print_status "Setting up vim/nvim configurations..."
    
    # Create nvim config directory
    mkdir -p "$HOME/.config/nvim"
    
    # Setup vim
    add_config_include "$CONFIG_DIR/vim/vim_config.vim" "$HOME/.vimrc"
    
    # Setup nvim
    add_config_include "$CONFIG_DIR/vim/nvim_config.vim" "$HOME/.config/nvim/init.vim"
}

# Setup git configurations
setup_git_configs() {
    print_status "Setting up git configurations..."
    
    if [ -f "$HOME/.gitconfig" ]; then
        add_config_include "$CONFIG_DIR/git/git_config" "$HOME/.gitconfig"
    fi
}

# Function to remove config include
remove_config_include() {
    local config_file="$1"
    local target_file="$2"
    local include_pattern="# Include $config_file"
    
    if [ -f "$target_file" ]; then
        # Create a temporary file
        local temp_file=$(mktemp)
        
        # Remove the include lines
        sed "/$include_pattern/,+1d" "$target_file" > "$temp_file"
        
        # Replace the original file
        mv "$temp_file" "$target_file"
        
        print_status "Removed $config_file from $target_file"
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

# Function to revert changes
revert() {
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No backup directory found!"
        exit 1
    fi
    
    # Get the most recent backup
    local latest_backup=$(ls -t "$BACKUP_DIR" | head -n1)
    if [ -z "$latest_backup" ]; then
        print_error "No backups found!"
        exit 1
    fi
    
    print_status "Reverting to backup: $latest_backup"
    
    # Restore files
    cp -r "$BACKUP_DIR/$latest_backup/"* "$HOME/"
    
    print_status "Revert completed successfully!"
    print_status "Please restart your terminal to apply changes"
}

# Parse command line arguments
case "$1" in
    "revert")
        revert
        ;;
    "list")
        list_configs
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_error "Please specify a config file to remove"
            exit 1
        fi
        remove_config_include "$2" "$3"
        ;;
    *)
        main
        ;;
esac 