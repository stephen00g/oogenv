# Setup vim/nvim configurations
setup_vim_configs() {
    print_status "Setting up vim/nvim configurations..."
    
    # Create nvim config directory
    mkdir -p "$HOME/.config/nvim"
    
    # Setup vim
    if [ -f "$HOME/.vimrc" ]; then
        add_config_include "$CONFIG_DIR/vim/vim_config.vim" "$HOME/.vimrc"
    fi
    
    # Setup nvim
    if [ -f "$HOME/.config/nvim/init.vim" ]; then
        # Remove any existing include lines
        sed -i '/# Include.*nvim_config.vim/d' "$HOME/.config/nvim/init.vim"
        sed -i '/source.*nvim_config.vim/d' "$HOME/.config/nvim/init.vim"
        
        # Add the include
        echo -e "\n# Include $CONFIG_DIR/vim/nvim_config.vim" >> "$HOME/.config/nvim/init.vim"
        echo "source $CONFIG_DIR/vim/nvim_config.vim" >> "$HOME/.config/nvim/init.vim"
    else
        # Create init.vim if it doesn't exist
        echo -e "# Include $CONFIG_DIR/vim/nvim_config.vim" > "$HOME/.config/nvim/init.vim"
        echo "source $CONFIG_DIR/vim/nvim_config.vim" >> "$HOME/.config/nvim/init.vim"
    fi
    
    # Create undodir for nvim
    mkdir -p "$HOME/.config/nvim/undodir"
}

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -h, --help     Display this help message"
    echo "  list           List all currently included configurations"
    echo "  remove         Remove a specific configuration"
    echo "                 Usage: $0 remove <config_file> <target_file>"
    echo "  revert         Revert to the previous configuration state"
    echo
    echo "Examples:"
    echo "  $0                    # Run the full setup"
    echo "  $0 list              # List all configurations"
    echo "  $0 remove ~/.vimrc   # Remove vim configuration"
    echo "  $0 revert            # Revert to previous state"
    echo
    echo "Configuration Files:"
    echo "  - Aliases:      $CONFIG_DIR/aliases/common_aliases.sh"
    echo "  - Shell:        $CONFIG_DIR/shell/bash_config.sh"
    echo "  - Vim:          $CONFIG_DIR/vim/vim_config.vim"
    echo "  - Neovim:       $CONFIG_DIR/vim/nvim_config.vim"
    echo "  - Git:          $CONFIG_DIR/git/git_config"
    echo
    echo "For more information, see the README.md file"
}

# Parse command line arguments
case "$1" in
    "-h"|"--help")
        show_help
        ;;
    "revert")
        revert
        ;;
    "list")
        list_configs
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_error "Please specify a config file to remove"
            echo
            show_help
            exit 1
        fi
        remove_config_include "$2" "$3"
        ;;
    *)
        main
        ;;
esac 