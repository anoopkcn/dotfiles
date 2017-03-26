let s:darwin = has('mac')
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

"======================[ PLUGINS ]====================================="
" Snippets variables
let g:snips_author='Anoop Chandran'
let g:author='Anoop Chandran'
let g:snips_email='strivetobelazy@gmail.com'
let g:email='strivetobelazy@gmail.com'
let g:snips_github='https://github.com/strivetobelazy'
let g:github='https://github.com/strivetobelazy'

