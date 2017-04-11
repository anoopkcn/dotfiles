"Plug plugin manager
call plug#begin('~/.conf/plugged')

"File Navigation
    Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    augroup nerd_loader
    autocmd!
    autocmd VimEnter * silent! autocmd! FileExplorer
    autocmd BufEnter,BufNew *
            \  if isdirectory(expand('<amatch>'))
            \|   call plug#load('nerdtree')
            \|   execute 'autocmd! nerd_loader'
            \| endif
    augroup END

"buffer navigation
    Plug 'bling/vim-bufferline'

" linter
    Plug 'neomake/neomake'
    Plug 'metakirby5/codi.vim'

" ctags append
    Plug 'craigemery/vim-autotag'
    " Plug 'majutsushi/tagbar'

"snippets
    Plug 'ervandew/supertab'
    Plug 'SirVer/ultisnips'
    Plug 'strivetobelazy/vim-snippets'

"Git
    Plug 'tpope/vim-fugitive'

"Code Formatting
    Plug 'tpope/vim-repeat'
    Plug 'tomtom/tcomment_vim'
    Plug 'tpope/vim-surround'
    Plug 'terryma/vim-multiple-cursors'

" Latex Support
    Plug 'vim-latex/vim-latex'

" YAML
    Plug 'stephpy/vim-yaml'

" language
    Plug 'beloglazov/vim-online-thesaurus'

" themes
    " Plug 'vim-airline/vim-airline'
    " Plug 'vim-airline/vim-airline-themes'

" Others
    Plug 'strivetobelazy/gruvbox'
    Plug 'mbbill/undotree'
    Plug 'justinmk/vim-gtfo'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'terryma/vim-smooth-scroll'
    Plug 'tpope/vim-tbone'

call plug#end()
