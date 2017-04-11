"--- ---[ General Settings ]-----------
let s:darwin = has('mac')

"change gutter colour
highlight clear SignColumn
" split separator for windows removed
hi VertSplit ctermbg=NONE guibg=NONE

"-------------------------[ Leader Mappings ]--------------------------------"
nnoremap <leader>n :bn<cr>
nnoremap <leader>p :bp<cr>
nnoremap <localleader>p <esc>:tabprevious<CR>
nnoremap <localleader>n <esc>:tabnext<CR>
nmap     <Leader>g :Gstatus<CR>gg<c-n>
nnoremap <Leader>d :Gdiff<CR>

" Remove extra white space
nnoremap <silent><leader>zz :call plugin#functions#trim_trailing()<cr>

" Redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>h :nohl<CR>

nnoremap <localleader>bs :cex []<BAR>bufdo vimgrepadd @@g %<BAR>cw<s-left><s-left><right>

"-----------------------------[ LocalLeader Mappings]------------------------"
" Create a file in the current dir and edit it
nnoremap <localleader>e :edit <C-R>=expand('%:p:h').'/'<CR>

" Toggle relative number "
nnoremap <silent><localleader>r :call plugin#functions#number_toggle()<cr>

" Toggle spell settings
nnoremap <localleader>l :call plugin#functions#spell()<CR>

"----------------------[ PLUGINS ]------------------------"
"fugitive
set diffopt+=vertical

"NerdTree
" <F10> | NERD Tree
nnoremap <leader>k :NERDTreeToggle<cr>

"undotree
" let g:undotree_WindowLayout = 2
nnoremap U :UndotreeToggle<CR>

"Ultisnips
let g:UltiSnipsExpandTrigger="<c-a>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:snips_author="Anoop Chandran"
let g:snips_email="strivetobelazy@gmail.com"
let g:snips_github="https://github.com/strivetobelazy"

" ----------------------------------------------------------------------------
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
    keepjumps exe '1,' . n . 's#^\(.\{,10}Last modified: \).*#\1' .
          \ strftime('%a %b %d, %Y  %I:%M%p') . '#e'
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
" EX | chmod +x

command! EX if !empty(expand('%'))
         \|   write
         \|   call system('chmod +x '.expand('%'))
         \|   silent e
         \| else
         \|   echohl WarningMsg
         \|   echo 'Save the file first'
         \|   echohl None
         \| endif

"---------------------------------------------------------------------------
" smooth scroll plugin
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 26, 1)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 25, 1)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2-2, 25, 1)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2-2, 25, 1)<CR>

"---------------------------------------------------------------------------
" rename tmux pane according to the buffer name
augroup vimrc
    " Automatic rename of tmux window
    if exists('$TMUX') && !exists('$NORENAME')
        au BufEnter * if empty(&buftype) | call system('tmux rename-window '.expand('%:t:S')) | endif
        au VimLeave * call system('tmux set-window automatic-rename on')
    endif
augroup END

"---------------------------------------------------------------------------
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

"---------------------------------------------------------------------------
" #!! | Shebang
inoreabbrev <expr> #!! "#!/usr/bin/env" . (empty(&filetype) ? '' : ' '.&filetype)

"---------------------------------------------------------------------------
" open atom
if s:darwin
  nnoremap <silent> <leader>1
  \ :call system('"atom" '.expand('%:p'))<cr>
endif

"---------------------------------------------------------------------------
" commandline settings
cnoremap        <C-A> <Home>
cnoremap        <C-B> <Left>
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
cnoremap        <M-b> <S-Left>
cnoremap        <M-f> <S-Right>
silent! exe "set <S-Left>=\<Esc>b"
silent! exe "set <S-Right>=\<Esc>f"


