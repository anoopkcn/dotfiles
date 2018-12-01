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

" Remove extra whitespace
function! Trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
endfunction

"" <Leader>?/! | Google it / Feeling lucky
function! s:goog(pat, lucky)
  let q = '"'.substitute(a:pat, '["\n]', ' ', 'g').'"'
  let q = substitute(q, '[[:punct:] ]',
      \ '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
  call system(printf('firefox "https://www.google.com/search?%sq=%s"',
                  \ a:lucky ? 'btnI&' : '', q))
endfunction

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
"
function! Insert_time()
  ":put =strftime(\"%d-%m-%Y %H:%M:%S \")
  let timestamp = strftime('%d-%m-%Y %H:%M')
  let @"=timestamp
endfunction

" Toggle laststatus between 1<->2
function! Toggle_laststatus()
  if &laststatus == 2
    set laststatus=1
  elseif &laststatus == 1
    set laststatus=2
  endif
  return
endfunction

" Toggle relative numbering
function! Number_toggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunction

"Spelling toggle
function! Spell()
  if !&spell
    set spell spelllang=en_gb
  else
    set nospell
  endif
endfunction

" Preview file in browser
function! Preview()
    "silent execute "!open -a 'firefox' " . shellescape(expand('%'))
    silent execute "!firefox " . shellescape(expand('%'))
endfunction
