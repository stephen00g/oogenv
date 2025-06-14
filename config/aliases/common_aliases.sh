# Common aliases for both bash and zsh

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List directory contents
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls --color=auto'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gl='git log'

# Editor shortcuts
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Configuration shortcuts
alias zshconfig="vim ~/.zshrc"
alias bashconfig="vim ~/.bashrc"
alias vimconfig="vim ~/.vimrc"
alias nvimconfig="vim ~/.config/nvim/init.vim"
alias gitconfig="vim ~/.gitconfig"

# System shortcuts
alias c='clear'
alias h='history'
alias j='jobs'
alias f='fg'
alias b='bg'

# Quick directory access
alias home='cd ~'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'
alias proj='cd ~/Projects'

# Process management
alias psg='ps aux | grep'
alias kill9='kill -9'

# Network
alias ip='curl -s https://api.ipify.org'
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv' 