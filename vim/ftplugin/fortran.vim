" Fortran
set shiftwidth=2
set softtabstop=2
set tabstop=2
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>81v.\+', -1) "Highli line>80 l
" Ensure correct syntax highlighting and auto-indentation for Fortran
let fortran_free_source=1
let fortran_do_enddo=1
autocmd BufNewFile,BufRead  *.f77,*.f90,*.f95,*.f03,*.f08 set filetype=fortran
" set makeprg=gfortran\ %<.f90\ -o\ %<
autocmd filetype fortran nnoremap <leader>e :w <bar> exec '!gfortran '
      \.shellescape('%').' -o '.shellescape('%:r').'
      \&& ./'.shellescape('%:r')<CR>
"Easy aligh
nnoremap <silent><leader>a :%EasyAlign /::/<CR>

iab <buffer> program PROGRAM
iab <buffer> end END
iab <buffer> implict IMPLICIT
iab <buffer> none NONE
iab <buffer> use USE
iab <buffer> character CHARACTER
iab <buffer> integer INTEGER
iab <buffer> real REAL
iab <buffer> parameter PARAMETER
iab <buffer> allocatable ALLOCATABLE
iab <buffer> allocate ALLOCATE
iab <buffer> print PRINT
iab <buffer> write WRITE
iab <buffer> read READ
iab <buffer> logical LOGICAL
iab <buffer> module MODULE
iab <buffer> function FUNCTION
iab <buffer> procedure PROCEDURE
iab <buffer> if IF
iab <buffer> then THEN
iab <buffer> else ELSE
iab <buffer> do DO
iab <buffer> while WHILE
iab <buffer> interface INTERFACE
iab <buffer> call CALL
iab <buffer> abs ABS
