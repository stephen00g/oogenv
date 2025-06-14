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