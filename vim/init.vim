"Vim Run Command File
"--------------------
set encoding=utf-8
scriptencoding utf-8
set nocompatible
unlet! skip_defaults_vim
let s:darwin = has('mac')

source ~/dotfiles/vim/fzf_functions.vim

source ~/dotfiles/vim/functions.vim
call plug#begin() "'~/.vim/plugged'
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-unimpaired'
  Plug 'tpope/vim-repeat'
  Plug 'https://github.com/github/copilot.vim.git'
call plug#end()
" :
"if s:darwin
"  let g:open_app = 'open'
"  set rtp+=/Users/chand/.homebrew/opt/fzf
"else
"  let g:open_app ='firefox'
"  set rtp+=/Users/chand/.linuxbrew/opt/fzf
"endif
"
" Swap, Undo and Backup files
if exists('$SUDO_USER')
    set nobackup
    set noswapfile
    set nowritebackup
    set noundofile
else
    let g:netrw_home=$HOME.'/.config/'
    set directory=$HOME/.config/vimswap//
    set backupdir=$HOME/.config/vimswap//
    set viewdir=$HOME/.config/views//
    set undofile "poor man's version controll
endif

if has("persistent_undo")
    set undodir=$HOME/.config/vimswap//
    set undofile
endif

"" Color Settings (compatable to gruvbox)
set t_Co=256
"set background=light
"colorscheme solarized
syntax on
filetype plugin indent on

if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

hi Error NONE
hi ErrorMsg NONE
hi Comment ctermfg=73
hi LineNr ctermfg=30

set number
" set relativenumber
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed
set autoindent
set expandtab
set shiftround
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4
" Folding setting
" set fdm=indent
" set nowrap
set wrap
set scrolloff=3
set shortmess=filnxtToOI
" set cursorline
" set nocursorline
set formatoptions+=1
set mouse=a
set path+=**
set wildmenu
set list
set listchars=nbsp:⦸
set listchars+=tab:\ \   "dont remove space
" set listchars+=tab:│\  "dont remove space
" set listchars+=eol:¬
set listchars+=extends:❯
set listchars+=precedes:❮
"set listchars+=trail:␣
" set fillchars+=vert:\|
set fillchars+=vert:\│ "dont remove space 
set nojoinspaces
set diffopt=filler,vertical
set splitright
set splitbelow
set omnifunc=syntaxcomplete#Complete
" set tags=tags;$HOME
set breakindent
if has('linebreak')
  set linebreak
  if s:darwin
    let &showbreak='⤷ '
  else
    let &showbreak='↳ '
  endif
  set breakindentopt=shift:2
endif

set visualbell t_vb=
set hidden
set autoread

" Search Settings
set hlsearch
set ignorecase
set smartcase
set incsearch

let mapleader ="\<Space>"
let maplocalleader = "\,"
"window switch
nnoremap <leader><leader> <c-w>
vnoremap < <gv
vnoremap > >gv
" wrapper line up and down
nnoremap j gj
nnoremap k gk
" nnoremap gj j
" nnoremap gk k
"
nnoremap 0 g0
nnoremap ^ g^  
nnoremap $ g$
" nnoremap g^ ^
" nnoremap g$ $
" nnoremap g0 0

" terminal mode Maps
" tnoremap <> <C-\><C-n> "anything except <esc>!!

" Custome function Maps
nnoremap <silent><leader>zz :call Trim_trailing()<cr>
"
":Root | Change directory to the root of the Git repository
function! s:root()
  let root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error
    echo 'Not in git repo'
  else
    execute 'lcd' root
    echo 'Changed directory to: '.root
  endif
endfunction

"" <Leader>?/! | Google it / Feeling lucky
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
      \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('%s "https://www.google.com/search?%sq=%s"', g:open_app,
                  \ a:lucky ? 'btnI&' : '', q))
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"), 0)<cr>
nnoremap <leader>! :call <SID>goog(expand("<cWORD>"), 1)<cr>
xnoremap <leader>? "gy:call <SID>goog(@g, 0)<cr>gv
xnoremap <leader>! "gy:call <SID>goog(@g, 1)<cr>gv

" Insert Time
inoremap <c-s-t> <esc>:call Insert_time()<cr>""pa
" Toggle relative number
" nnoremap <leader>t :call Insert_time()<cr>""p

" Create and edit file
" nnoremap <silent> <Leader>h :nohl<CR>
nnoremap <leader>n :tabnext<cr>
nnoremap <leader>p :tabprevious<cr>

" Command line Readline settings
cnoremap        <C-A> <Home>
cnoremap        <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
cnoremap        <M-b> <S-Left>
cnoremap        <M-f> <S-Right>
silent! exe "set <S-Left>=\<Esc>b"
silent! exe "set <S-Right>=\<Esc>f"
"
" Turn on spell cheking for filetypes
autocmd FileType latex,tex,md,markdown,gitcommit setlocal spell spelllang=en_gb
command! Root call s:root()
command! Preview :call Preview()
command! Lchange :call Lchange()
" autocmd BufWritePre * call LastModified()
autocmd InsertEnter * :setlocal nohlsearch
"
" Remove extra whitespace
function! Trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction
" If buffer modified, update any 'Last modified: ' in the first 20 lines.
function! Lchange()
  if &modified
    let save_cursor = getpos(".")
    let n = min([20, line("$")])
    keepjumps exe '1,' . n . 's#^\(.\{,10}Last Modified: \).*#\1' . strftime('%d-%m-%Y %H:%M') . '#e'
    call histdel('search', -1)
    call setpos('.', save_cursor)
  endif
endfun
"
function! Insert_time()
  ":put =strftime(\"%d-%m-%Y %H:%M:%S \")
  let timestamp = strftime('%d-%m-%Y %H:%M')
  let @"=timestamp
endfunction

" Preview file in browser
function! Preview()
    "silent execute "!open -a 'firefox' " . shellescape(expand('%'))
    silent execute "!".g:open_app." ".shellescape(expand('%'))
endfunction
" autogroup
augroup inp_ft
  au!
  autocmd BufNewFile,BufRead *.inp   set ft=sh
augroup END

"-------------- PLUGIN Settings ----------------------"
"
" Fugitive
" Delete buffer on leave
autocmd BufReadPost fugitive://* set bufhidden=delete
"
" GitGutter
set updatetime=100
"FZF-keybindings
nnoremap <silent> <leader>f :GFiles<CR>
nnoremap <silent> <localleader>f :Files<CR>
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>/ :Rg<CR>
nnoremap <localleader>/ :Ag<CR>
nnoremap <leader>t :Tags<CR>
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)
"
" Additional functions
nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
 " Remember cursor position
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

set laststatus=0
let g:copilot_node_command = '/usr/local/n/versions/node/17.0.0/bin/node'
