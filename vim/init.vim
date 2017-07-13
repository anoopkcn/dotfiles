" -------
" Vim run command file
" -------
scriptencoding utf-8
set nocompatible
unlet! skip_defaults_vim
syntax on
filetype plugin indent on

set background=dark
colorscheme PaperColor
set guifont=Monaco:h14

set number
"set relativenumber
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed

" TAB settings "
set autoindent
set expandtab
set shiftround
set shiftwidth=2
set smartindent
set softtabstop=2
set tabstop=2

" Folding setting
" set fdm=indent
set nowrap

set scrolloff=3
set shortmess=filnxtToOI
set nocursorline
set formatoptions+=1
set mouse=a

set path+=**
set wildmenu

set list
set listchars=nbsp:⦸
set listchars+=tab:▸\ 
set listchars+=tab:\ \ 
" set listchars+=eol:¬
set listchars+=extends:❯
set listchars+=precedes:❮
"set listchars+=trail:␣

set nojoinspaces
set diffopt=filler,vertical
set splitright
set splitbelow
set omnifunc=syntaxcomplete#Complete
set tags=tags;$HOME

if has('linebreak')
    set linebreak
    let &showbreak='⤷ '
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
vnoremap < <gv
vnoremap > >gv

nnoremap j gj
nnoremap k gk
nnoremap ^ g^
nnoremap 0 g0
nnoremap $ g$
nnoremap gj j
nnoremap gk k
nnoremap g^ ^
nnoremap g$ $
nnoremap g0 0

" noremap <Up> <NOP>
" noremap <Down> <NOP>
" noremap <Left> <NOP>
" noremap <Right> <NOP>

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

autocmd InsertEnter * :setlocal nohlsearch

" plugins
call plug#begin('~/.vim/bundle')
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'neomake/neomake'
    Plug 'ervandew/supertab'
    Plug 'kien/ctrlp.vim'
    Plug 'scrooloose/nerdtree'
    Plug 'airblade/vim-gitgutter'
    Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
    Plug 'terryma/vim-smooth-scroll'
call plug#end()
if has('gui')
  " Turn off scrollbars. (Default on macOS is "egmrL").
  set guioptions-=L
  set guioptions-=R
  set guioptions-=b
  set guioptions-=l
  set guioptions-=r

else "Run the following only on terminal

  "fzf settings
  let g:fzf_layout = { 'down': '~35%' }
  let g:fzf_history_dir = '~/.conf/fzf-history'

  " nnoremap <leader><leader> :Files<cr>
  " nnoremap <silent> <leader>b :Buffers<cr>
  " nnoremap <leader>t :Tags  " easy tags
  " nnoremap <silent> <Leader>` :Marks<CR>


  command! -bang -nargs=* Ag
    \ call fzf#vim#ag(<q-args>,
    \                 <bang>0 ? fzf#vim#with_preview('up:60%')
    \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
    \                 <bang>0)

  command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

  " Openup browser to preview markdown
  function! Preview()
      silent execute "!open -a 'Google\ Chrome.app' " . shellescape(expand('%'))
  endfunction
  command! Preview :call Preview()

  nnoremap <leader>f :Ag<space>

endif "TERMINAL endif


" FOR ALL PLATFORMS
"---------------------------------------------------------------------------
" My functions
" augroup vimrc
"     " Automatic rename of tmux window
"     if exists('$TMUX') && !exists('$NORENAME')
"         au BufEnter * if empty(&buftype) | call system('tmux rename-window '.expand('%:t:S')) | endif
"         au VimLeave * call system('tmux set-window automatic-rename on')
"     endif
" augroup END

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
command! Root call s:root()

" Remove extra whitespace
function! Trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction
nnoremap <silent><leader>zz :call Trim_trailing()<cr>

"" <Leader>?/! | Google it / Feeling lucky
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
      \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('open "https://www.google.com/search?%sq=%s"',
                  \ a:lucky ? 'btnI&' : '', q))
endfunction

nnoremap <leader>? :call <SID>goog(expand("<cWORD>"), 0)<cr>
nnoremap <leader>! :call <SID>goog(expand("<cWORD>"), 1)<cr>
xnoremap <leader>? "gy:call <SID>goog(@g, 0)<cr>gv
xnoremap <leader>! "gy:call <SID>goog(@g, 1)<cr>gv

" ----------------------------------------------------------------------------
" ?ii / ?ai | indent-object
" ?io       | strictly-indent-object
function! s:indent_len(str)
  return type(a:str) == 1 ? len(matchstr(a:str, '^\s*')) : 0
endfunction

" ----------------------------------------------------------------------------
" #gi / #gpi | go to next/previous indentation level
function! s:go_indent(times, dir)
  for _ in range(a:times)
    let l = line('.')
    let x = line('$')
    let i = s:indent_len(getline(l))
    let e = empty(getline(l))

    while l >= 1 && l <= x
      let line = getline(l + a:dir)
      let l += a:dir
      if s:indent_len(line) != i || empty(line) != e
        break
      endif
    endwhile
    let l = min([max([1, l]), x])
    execute 'normal! '. l .'G^'
  endfor
endfunction
nnoremap <silent> gi :<c-u>call <SID>go_indent(v:count1, 1)<cr>
nnoremap <silent> gpi :<c-u>call <SID>go_indent(v:count1, -1)<cr>

"---------------------------------------------------------------------------
" If buffer modified, update any 'Last modified: ' in the first 20 lines.
function! LastModified()
  if &modified
    let save_cursor = getpos(".")
    let n = min([20, line("$")])
    keepjumps exe '1,' . n . 's#^\(.\{,10}Last Modified: \).*#\1' .
          \ strftime('%d-%m-%Y %H:%M') . '#e'
    call histdel('search', -1)
    call setpos('.', save_cursor)
  endif
endfun
autocmd BufWritePre * call LastModified()

"---------------------------------------------------------------------------
"Shows a list of places where TODO/FIXME/XXX is written
function! s:todo() abort
  let entries = []
  for cmd in ['git grep -niI -e TODO -e FIXME -e XXX 2> /dev/null',
            \ 'grep -rniI -e TODO -e FIXME -e XXX * 2> /dev/null']
    let lines = split(system(cmd), '\n')
    if v:shell_error != 0 | continue | endif
    for line in lines
      let [fname, lno, text] = matchlist(line, '^\([^:]*\):\([^:]*\):\(.*\)')[1:3]
      call add(entries, { 'filename': fname, 'lnum': lno, 'text': text })
    endfor
    break
  endfor

  if !empty(entries)
    call setqflist(entries)
    copen
  endif
endfunction
command! Todo call s:todo()

" ----------------------------------------------------------------------------
" Close preview window
  if exists('##CompleteDone')
    au CompleteDone * pclose
  else
    au InsertLeave * if !pumvisible() && (!exists('*getcmdwintype') || empty(getcmdwintype())) | pclose | endif
  endif

" ------------------------------------------------------------------
" commandline settings
cnoremap        <C-A> <Home>
cnoremap        <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
cnoremap        <M-b> <S-Left>
cnoremap        <M-f> <S-Right>
silent! exe "set <S-Left>=\<Esc>b"
silent! exe "set <S-Right>=\<Esc>f"

"---------------------------------------------------------------------------
set laststatus=2
" Status line settings
set statusline=%<[%n]\ %F\ %m%r%y\ %=%-14.(%l,%c%V%)\ %P\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}

" Toggle laststatus between 1<->2
function! Toggle_laststatus()
  if &laststatus == 2
    set laststatus=1
  elseif &laststatus == 1
    set laststatus=2
  endif
  return
endfunction

" Toggle Status line
nnoremap <silent> <leader>l :call Toggle_laststatus()<cr>

" Toggle relative numbering
function! Number_toggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunction
" Toggle relative number "
nnoremap <silent><localleader>r :call Number_toggle()<cr>

"Spelling toggle
function! Spell()
  if !&spell
    set spell spelllang=en_gb
  else
    set nospell
  endif
endfunction
" Toggle spell settings
nnoremap <localleader>l :call Spell()<CR>

function! Insert_time()
  ":put =strftime(\"%d-%m-%Y %H:%M:%S \")
  let timestamp = strftime('%d-%m-%Y %H:%M')
  let @"=timestamp
endfunction
nnoremap <Leader>t :call Insert_time()<cr>""p 
inoremap <c-s-t> <esc>:call Insert_time()<cr>""pa


"create and edit file
nnoremap <localleader>e :edit <C-R>=expand('%:p:h').'/'<CR>

nnoremap <silent> <Leader>h :nohl<CR>

"turn on spell cheking for filetypes
autocmd FileType latex,tex,md,markdown,gitcommit setlocal spell spelllang=en_gb
"---------------------------------------------------------------------------
" Plugin setttings

nnoremap <leader>n :bn<cr>
nnoremap <leader>p :bp<cr>
nnoremap <localleader>p <esc>:tabprevious<CR>
nnoremap <localleader>n <esc>:tabnext<CR>
nmap     <Leader>g :Gstatus<CR>gg<c-n>
nnoremap <Leader>d :Gdiff<CR>

"for fugitive
set diffopt+=vertical

let g:ctrlp_map = '<leader><leader>'
let g:ctrlp_cmd = 'CtrlP'
nnoremap <silent> <leader>b :CtrlPBuffer<cr>

"file explorer opt
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

hi WarningMsg        ctermfg=131    ctermbg=NONE     cterm=bold
hi ErrorMsg          ctermfg=131    ctermbg=NONE   cterm=NONE
" hi LineNr            ctermfg=blue        ctermbg=NONE        cterm=NONE
hi IncSearch         ctermbg=green
hi Search            ctermfg=grey ctermbg=148 cterm=NONE
hi clear SignColumn
hi StatusLine ctermbg=NONE ctermfg=231 cterm=NONE
hi StatusLineNC ctermbg=NONE cterm=NONE

" Smooth scroll plugin settings
noremap <silent> <c-e> :call smooth_scroll#up(&scroll, 30, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 30, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 30, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 30, 4)<CR>

