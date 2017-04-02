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

"linter
    Plug 'neomake/neomake'
    Plug 'metakirby5/codi.vim'

" ctags append
    Plug 'craigemery/vim-autotag'

"snippets
    Plug 'SirVer/ultisnips'
    Plug 'strivetobelazy/vim-snippets'
"Git
    Plug 'tpope/vim-fugitive'

"Code Formatting
    Plug 'tomtom/tcomment_vim'
    Plug 'tpope/vim-surround'
    Plug 'terryma/vim-multiple-cursors'

"Latex Support
    Plug 'vim-latex/vim-latex'

"YAML
    Plug 'stephpy/vim-yaml'

"Others
    " Plug 'morhetz/gruvbox'
    Plug 'NLKNguyen/papercolor-theme'
    Plug 'mbbill/undotree'

call plug#end()
