set nocompatible                " disable compatibility to old-time vi
set showmatch                   " show matching 
set ignorecase                  " case insensitive 
set mouse=v                     " middle-click paste with 
set hlsearch                    " highlight search 
set incsearch                   " incremental search
set tabstop=4                   " number of columns occupied by a tab 
set softtabstop=4               " see multiple spaces as tabstops so <BS> does the right thing
set expandtab                   " converts tabs to white space
set shiftwidth=4                " width for autoindents
set autoindent                  " indent a new line the same amount as the line just typed
set number                      " add line numbers
set wildmode=longest,list       " get bash-like tab completions
filetype plugin indent on       " allow auto-indenting depending on file type
syntax on                       " syntax highlighting
set clipboard=unnamedplus       " using system clipboard
filetype plugin on              " enable filetype detection
set cursorline                  " highlight current cursorline
set ttyfast                     " Speed up scrolling in Vim
let mapleader="\,"              " Set leader key to be comma rather than the default backslash
" set mouse=a                   " enable mouse click
" set cc=80                     " set an 80 column border for good coding style
" set spell                     " enable spell check (may need to download language package)
" set noswapfile                " disable creating swap file
" set backupdir=~/.vimcache     " Directory to store backup files.

call plug#begin()
Plug 'nvim-lua/plenary.nvim'                        " dependancy for telescope
Plug 'nvim-telescope/telescope.nvim'                " fuzzy file search and preview plugin
Plug 'tpope/vim-surround'                           " vim motion to change surround pattern
Plug 'tpope/vim-repeat'                             " repeat non-native motions with . key
Plug 'shaunsingh/nord.nvim'                         " color scheme nord for vim
Plug 'https://github.com/github/copilot.vim.git'    " github copilot plugin for vim
call plug#end()

" Set colorscheme
colorscheme nord

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" Set relative line numbers
nnoremap <leader>n :set relativenumber!<cr>     

