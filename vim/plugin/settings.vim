"
"=======[ General Settings ]===========
let s:darwin = has('mac')

"-------------------------[ Leader Mappings ]--------------------------------"
nnoremap <Leader>p <esc>:tabprevious<CR>
nnoremap <Leader>n <esc>:tabnext<CR>

" Remove extra whitespace
nnoremap <silent><leader>zz :call plugin#functions#trim_trailing()<cr>

" Redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>h :nohl<CR>

" Toggle Status line
set statusline=%<[%n]\ %F\ %m%r%y\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}\ %=%-14.(%l,%c%V%)\ %P
nnoremap <silent> <leader>l :call plugin#functions#toggle_laststatus()<cr>

"-----------------------------[ LocalLeader Mappings]------------------------"
" Create a file in the current dir and edit it
nnoremap <localleader>e :edit <C-R>=expand('%:p:h').'/'<CR>

" Toggle relative number "
nnoremap <silent><localleader>n :call plugin#functions#number_toggle()<cr>

" Toggle spell settings
nnoremap <localleader>l :call plugin#functions#spell()<CR>


"===============================[ LANGUAGE ]==========================="
" Spell settings for plintext  markdown and gitcommit
autocmd BufNewFile,BufReadPost *.md,*.txt,*.html,gitcommit call plugin#functions#plaintext()

" Git
autocmd Filetype gitcommit setlocal textwidth=72
au FileType gitcommit nnoremap <buffer> <silent> cd :<C-U>Gcommit --amend --date="$(date)"<CR>

" HTML
au BufReadPost *.html,htm set syntax=html

" Gnuplot
au BufNewFile,BufRead *.gpl,*.gp setf sh
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

" #!! | Shebang
inoreabbrev <expr> #!! "#!/usr/bin/env" . (empty(&filetype) ? '' : ' '.&filetype)

" open atom
if s:darwin
  nnoremap <silent> <leader>ia
  \ :call system('"atom" '.expand('%:p'))<cr>
endif

"======================[ PLUGINS ]========================"
"fugitive
set diffopt+=vertical

"NerdTree
" <F10> | NERD Tree
nnoremap <C-k> :NERDTreeToggle<cr>

"Ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

"" <Leader>?/! | Google it / Feeling lucky
" ----------------------------------------------------------------------------
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

"fzf file completioa and other functions
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
