" Fortran
set shiftwidth=2
set softtabstop=2
set tabstop=2
highlight OverLength ctermfg=red cterm=underline
au BufWinEnter * let w:m2=matchadd('OverLength', '\%>81v.\+', -1) "Highli line>80 l
" Ensure correct syntax highlighting and auto-indentation for Fortran
let fortran_free_source=1
let fortran_do_enddo=1
autocmd BufNewFile,BufRead  *.f77,*.f90,*.f95,*.f03,*.f08 set filetype=fortran
