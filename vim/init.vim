"                   RUN COMMANDS (rc) file for Vi[M]
"-----------------------------------------------------------------------
"- BASIC
"- MAPPINGS
"- LANGUAGE
"- PLUGINS

"Plugins.vim file containing all the plugin settings except the keymap(bottom)
"Functions.vim file contains all the functions that are used in this file
"[ Tip: go to file using `gf` and `<c+o>` to come back. For opening in a new
"window use `<c-w>f` or `<c-w>gf` to open it in a new tab. ]
scriptencoding utf-8

source $HOME/.dotfiles/vim/plugin/plugins.vim
source $HOME/.dotfiles/vim/plugin/functions.vim

"=====================[ BASIC ]========================================"

set nocompatible "Remove back compatability for vi
filetype off
syntax enable
filetype plugin indent on
set shellcmdflag=-ic "Exicute shell commands in vim
set number "relative number is a toogle function <leader>n
set showmatch "Show matching [] and {}
set formatoptions+=r formatoptions+=c
set modifiable
set cursorline
" set foldmethod=indent

" set clipboard+=unnamed "Compile with +clipboard block paste doent work
"to check `vim --version | grep clipboard`

set visualbell t_vb= "setting visual bell to null

set hidden                            " allows you to hide buffers with unsaved changes without being prompted

"Search Settings
set hlsearch
set ignorecase
"set incsearch
set smartcase

"Swap, Undo and Backup files
if exists('$SUDO_USER')
	set nobackup
	set noswapfile
	set nowritebackup
	set noundofile
else
	let g:netrw_home=$HOME.'/.tmp/'
	set directory=$HOME/.tmp/vimswap//
	set backupdir=$HOME/.tmp/vimswap//
	set undodir=$HOME/.tmp/vimswap//
    set viewdir=$HOME/.tmp/views//
	set undofile "poor man's version controll
endif

"Remember where i left off
au BufWinLeave ?* mkview
au BufWinEnter ?* silent! loadview

set switchbuf=usetab
set path+=** "Fuzzy file search
set wildmenu "Display all matching files on tab complete
set complete+=kspell

"TAB settings "
set autoindent
set expandtab
set shiftround
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4

set scrolloff=3                       " start scrolling 3 lines before edge of viewport
" set shortmess+=A                      " ignore annoying swapfile messages
set shortmess+=I                      " no splash screen
set shortmess+=O                      " file-read message overwrites previous
set shortmess+=T                      " truncate non-file messages in middle
set shortmess+=W                      " don't echo "[w]"/"[written]" when writing
set shortmess+=a                      " use abbreviations in messages eg. `[RO]` instead of `[readonly]`
set shortmess+=o                      " overwrite file-written messages
set shortmess+=t                      " truncate file messages at start

"Show Tabline
" set showtabline=2
"Status line settings"
set statusline=
" set statusline=[%n]\ %<%.99f\ %h%w%m%r%y%=%-12(\ %c,%l/%L\ %)%P\ %{fugitive#statusline()}
" hi StatusLine ctermbg=NONE ctermfg=3  cterm=NONE "transparent statusline

"Theme Settings"
if has('gui_running')
    set guioptions-=r
    set guioptions-=L
else
    set encoding=utf-8  "UTF-8 encoding to show certain characters
    set t_Co=256  " Setting terminal to 256 color scheme
	set background=dark
	colorscheme solarized
endif


"80 Character Limit "
" au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>81v.\+', -1) "Highli line>80 l
" OR
" if exists('+colorcolumn')
" 	let &l:colorcolumn='+'.join(range(0,254),',+')
" endif


if has('linebreak')
  set linebreak                       " wrap long lines at characters in 'breakat'
endif

set list                              " show whitespace
set listchars=nbsp:⦸
set listchars+=tab:⇥\ 
" set listchars+=eol:¬
" set listchars+=trail:⋅
set listchars+=extends:❯
set listchars+=precedes:❮
set listchars+=trail:•
set nojoinspaces                      " don't autoinsert two spaces after '.', '?', '!' for join command
set fillchars+=vert:│
hi VertSplit ctermbg=NONE guibg=NONE

if has('linebreak')
  let &showbreak='⤷ '               " ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS (U+2937, UTF-8: E2 A4 B7)
endif

if has('linebreak')
	set breakindent
	if exists('&breakindentopt')
		set breakindentopt=shift:2
	endif
endif

if has('folding')
	if has('windows')
		set fillchars+=vert:│
	endif
	set foldmethod=indent
	set foldlevelstart=99
endif


set whichwrap=b,h,l,s,<,>,[,],~
set wildmode=longest:full,full


"====================[ MAPPINGS ]====================================="
" Remapping the leader key
let mapleader ="\<Space>"
let maplocalleader = "\\"

let g:netrw_banner       = 0
let g:netrw_liststyle    = 3
let g:netrw_sort_options = 'i'
let g:netrw_winsize = 25
" let g:netrw_altv=1
" let g:netrw_browse_split = 4
" let g:netrw_dirhistmax = 0 "store no history or bookmarks

" Remove bad Habits
" noremap <Up> <NOP>
" noremap <Down> <NOP>
" noremap <Left> <NOP>
" noremap <Right> <NOP>

" Prevent Ex-mode
nnoremap q: <Nop>
nnoremap Q <Nop>

" Remaping basic keys
" nnoremap ; :

" Using the dot . to repeat in the visualmode as well
vnoremap . :normal .<CR>

"readline like behaviour for beging and end of the line
nnoremap 9 g_

"Enable magic mode for regex
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
" Switching tabs
nnoremap tn :Texplore<CR>
map <Leader>p <esc>:tabprevious<CR>
map <Leader>n <esc>:tabnext<CR>

" Moving around in split windows
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Easier indentation of lines/blocks without losing the visualmode selection
vnoremap < <gv
vnoremap > >gv

" Easier formatting of paragrphs
vmap Q gq
nmap Q gqap

"multy variable change
nnoremap c* *Ncgn

" Sorting words or characters alphabetically
" noremap <Leader>s :sort<CR>

nnoremap <leader>k :Vexplore<CR>
"create a file in the current dir and edit it
nnoremap <localleader>e :edit <C-R>=expand('%:p:h').'/'<CR>

"Toggle relative number "
nnoremap <silent><localleader>n :call plugin#functions#number_toggle()<cr>

" Remove extra whitespace
nmap <silent><leader>zz :call plugin#functions#trim_trailing()<cr>

" Redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>h :nohl<CR>

"Toggle Status line
nnoremap <silent> <leader>l :call plugin#functions#toggle_laststatus()<cr>


map <localleader>l :call plugin#functions#spell()<CR>
imap <localleader>l :call plugin#functions#spell()<CR>

"Ignore certain things
set wildignore+=*.a,*.o
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png
set wildignore+=.DS_Store,.hg,.svn
set wildignore+=*~,*.swp,*.tmp


"===============================[ LANGUAGE ]==========================="
"Spell Settings
" set spell spelllang=en_gb
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline


"Git
autocmd Filetype gitcommit setlocal textwidth=72

"HTML
au BufReadPost *.html,htm set syntax=html

"Gnuplot
au BufNewFile,BufRead *.gpl,*.gp setf sh

runtime macros/matchit.vim

