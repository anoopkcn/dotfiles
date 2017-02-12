"==============[ Vim Functions ]==============="
"plaintext settings
function! plugin#functions#plaintext() abort
  setlocal nolist
  setlocal spell
  setlocal textwidth=0
  setlocal wrap
  setlocal wrapmargin=0

  nnoremap <buffer> j gj
  nnoremap <buffer> k gk

  " Ideally would keep 'list' set, and restrict 'listchars' to just show
  " whitespace errors, but 'listchars' is global and I don't want to go through
  " the hassle of saving and restoring.
  if has('autocmd')
    autocmd BufWinEnter <buffer> match Error /\s\+$/
    autocmd InsertEnter <buffer> match Error /\s\+\%#\@<!$/
    autocmd InsertLeave <buffer> match Error /\s\+$/
    autocmd BufWinLeave <buffer> call clearmatches()
  endif
endfunction

function! s:preview(file)
  " let ext=expand('%:e')
  " if (ext=='md'||ext=='markdown'||ext=='rst')
    " silent execute "!open -a 'Markoff.app' " . shellescape(a:file)
    " redraw!
  " else
    silent execute "!open -a 'Google\ Chrome.app' " . shellescape(a:file)
    redraw!
  " endif
endfunction

function! plugin#functions#preview(...)
  if a:0 == 0
    call s:preview(expand('%'))
  else
    for l:file in a:000
      call s:preview(l:file)
    endfor
  endif
endfunction


" Remove extra whitespace
function! plugin#functions#trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction


" Toggle laststatus between 1<->2
function! plugin#functions#toggle_laststatus()
  if &laststatus == 2
    set laststatus=1
  elseif &laststatus == 1
    set laststatus=2
  endif
  return
endfunction


" Toggle relative numbering
function! plugin#functions#number_toggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunc

"Spelling toggle
function! plugin#functions#spell()
  if !&spell
    set spell spelllang=en_gb
  else
    set nospell
  endif
endfunction

"Build Sub Directory if doesnt exists
"Form : Damian Conway
function! plugin#functions#ask_quit(msg, options, quit_option)
  if confirm(a:msg, a:options) == a:quit_option
      exit
  endif
endfunction

function! plugin#functions#ensure_dir_exists ()
let required_dir = expand("%:h")
if !isdirectory(required_dir)
    call plugin#functions#ask_quit("Parent directory '" . required_dir . "' doesn't exist.",
          \"&Create it\nor &Quit?", 2)
    try
        call mkdir( required_dir, 'p' )
    catch
        call plugin#functions#ask_quit("Can't create '" . required_dir . "'",
              \"&Quit\nor &Continue anyway?", 1)
    endtry
endif
endfunction

augroup AutoMkdir
  autocmd!
  autocmd  BufNewFile  *  :call plugin#functions#ensure_dir_exists()
augroup END

