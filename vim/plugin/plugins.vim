"Plug plugin manager
call plug#begin('~/.conf/plugged')
"File Navigation
  Plug 'kien/ctrlp.vim'
  Plug 'tacahiroy/ctrlp-funky'
  Plug 'tpope/vim-vinegar'
"linter
 Plug 'neomake/neomake'
"Autocomplete
  Plug 'Valloric/YouCompleteMe'
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
"html
  Plug 'mattn/emmet-vim'
"YAML
 Plug 'stephpy/vim-yaml'
"Others
  " Plug 'strivetobelazy/vim-startify' "forked from mhinz
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'airblade/vim-gitgutter'
  Plug 'morhetz/gruvbox'
call plug#end()
