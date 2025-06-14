" Neovim configuration

" Basic settings
set nocompatible
set number
set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set clipboard=unnamedplus
set encoding=utf-8
set fileencoding=utf-8
set termguicolors
set background=dark
set cursorline
set showmatch
set ignorecase
set smartcase
set hlsearch
set incsearch
set nobackup
set noswapfile
set undodir=~/.config/nvim/undodir
set undofile
set scrolloff=8
set signcolumn=yes
set colorcolumn=80
set list
set listchars=tab:>·,trail:·,extends:>,precedes:<

" Enable syntax highlighting
syntax on

" Set color scheme
try
    colorscheme desert
catch
    colorscheme default
endtry

" Key mappings
let mapleader = " "

" Normal mode mappings
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <leader>ps :Rg<SPACE>
nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>

" Split window
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>s :split<CR>

" Buffer navigation
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>
nnoremap <leader>bd :bd<CR>

" Search
nnoremap <leader>nh :nohl<CR>

" Save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" Plugin management with vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" File navigation
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Language support (lighter alternative to coc.nvim)
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'  " Lightweight linter

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Editing helpers
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'jiangmiao/auto-pairs'
Plug 'farmergreg/vim-lastplace'  " Remember last cursor position

call plug#end()

" Theme settings
colorscheme gruvbox

" NERDTree settings
let NERDTreeShowHidden=1
nmap <C-n> :NERDTreeToggle<CR>

" FZF settings
nmap <C-p> :Files<CR>
nmap <C-g> :GFiles<CR>

" ALE settings
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\   'go': ['gofmt', 'golint'],
\   'rust': ['rustc', 'cargo'],
\}

let g:ale_fixers = {
\   'python': ['black', 'isort'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'go': ['gofmt'],
\   'rust': ['rustfmt'],
\}

let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 1

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'

" Key mappings
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Search settings
nnoremap <silent> <Esc> :nohlsearch<CR>

" Terminal settings
tnoremap <Esc> <C-\><C-n>

" Load any local nvim configuration
if filereadable(expand("~/.config/nvim/init.vim.local"))
    source ~/.config/nvim/init.vim.local
endif 