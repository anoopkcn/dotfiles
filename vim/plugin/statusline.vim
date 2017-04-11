" Status line settings

hi StatusLineNC ctermbg=239 ctermfg=235
hi StatusLine ctermbg=230 ctermfg=235

set statusline=%<[%n]\ %F\ %m%r%y\ %=%-14.(%l,%c%V%)\ %P\ %{exists('g:loaded_fugitive')?fugitive#statusline():''}

" Toggle Status line
nnoremap <silent> <leader>l :call plugin#functions#toggle_laststatus()<cr>
