"Plug plugin manager
call plug#begin('~/.conf/plugged')
"File Navigation
  " Plug 'kien/ctrlp.vim'
  Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
  Plug 'tacahiroy/ctrlp-funky'
  Plug 'tpope/vim-vinegar'
"linter
  Plug 'neomake/neomake'
" ctags append
  Plug 'craigemery/vim-autotag'
"Autocomplete
  " Plug 'Valloric/YouCompleteMe'
"snippets
  Plug 'SirVer/ultisnips'
  Plug 'honza/vim-snippets'
"Git
  Plug 'tpope/vim-fugitive'
"Code Formatting
  Plug 'tomtom/tcomment_vim'
  Plug 'tpope/vim-surround'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'godlygeek/tabular'
"Latex Support
  Plug 'vim-latex/vim-latex'
"YAML
    Plug 'stephpy/vim-yaml'
"Others
  " Plug 'morhetz/gruvbox'
  Plug 'NLKNguyen/papercolor-theme'
call plug#end()
