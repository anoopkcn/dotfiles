"fzf settings

let g:fzf_layout = { 'down': '~30%' }

let g:fzf_history_dir = '~/.local/share/fzf-history'

"maps
inoremap <expr> <c-x><c-k> fzf#complete('cat /usr/share/dict/words')
nnoremap <leader>f :Files<cr>
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>t :Tags 
nnoremap <leader>g :Ag 

