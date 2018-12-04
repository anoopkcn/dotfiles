" Remove extra whitespace
function! Trim_trailing()
    if search('\s\+$', 'cnw')
        :%s/\s\+$//g
    endif
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
