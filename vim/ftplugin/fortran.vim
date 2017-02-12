" Fortran
set shiftwidth=2
set softtabstop=2
set tabstop=2
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>81v.\+', -1) "Highli line>80 l
" Ensure correct syntax highlighting and auto-indentation for Fortran
let fortran_free_source=1
let fortran_do_enddo=1
autocmd BufNewFile,BufRead  *.f90,*.f95,*.f03 set filetype=fortran
" set makeprg=gfortran\ %<.f90\ -o\ %<
autocmd filetype fortran nnoremap <leader>e :w <bar> exec '!gfortran '
      \.shellescape('%').' -o '.shellescape('%:r').'
      \&& ./'.shellescape('%:r')<CR>
"Easy aligh
nnoremap <silent><leader>a :%EasyAlign /::/<CR>
