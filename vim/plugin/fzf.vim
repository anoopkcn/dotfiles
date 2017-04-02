"fzf settings

let g:fzf_layout = { 'down': '~35%' }

let g:fzf_history_dir = '~/.conf/fzf-history'


"maps
" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#complete('cat /usr/share/dict/words')

" nnoremap <leader><leader> :Files<cr>
nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
nnoremap <silent> <leader>b :call Myb()<cr>
nnoremap <leader>t :Tags 
nnoremap <leader>g :Ag 

function! Myb()
    if bufnr('$')<'4'
        :bn
    else
        :Buffers
    endif
endfunction
