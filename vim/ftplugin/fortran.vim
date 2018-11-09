"Language Specific
let fortran_have_tabs=1
let fortran_more_precise=1
let fortran_do_enddo=1
" let fortran_free_source=1
let s:extfname = expand("%:e")
if s:extfname ==? "f90"
  let fortran_free_source=1
  unlet! fortran_fixed_source
else
  let fortran_fixed_source=1
  unlet! fortran_free_source
endif
