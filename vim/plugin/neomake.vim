"Neomake
autocmd! BufWritePost *.f90,*.f03,*.f08,*.c,*.cpp,*.go Neomake

highlight NeomakeErrorSign ctermfg=red
highlight NeomakeErrorMsg ctermfg=227
"ctermbg=237
" let g:neomake_verbose=3
let g:neomake_error_sign = {'texthl': 'NeomakeErrorSign', 'text': '✗'}
let g:neomake_warning_sign={'texthl': 'NeomakeErrorMsg', 'text': '⚠'}
let g:neomake_message_sign = {'texthl': 'NeomakeMessageSign', 'text': '¶'}
let g:neomake_info_sign = {'texthl': 'MyInfoMsg', 'text': '☂'}

let g:neomake_c_enabled_makers = ['gcc']
let g:neomake_cpp_enabled_makers = ['gcc']
let g:neomake_fortran_enabled_makers = ['gfortran']

let g:neomake_c_gcc_maker = {
            \'args':[
            \'-Os','-g',
            \'-Wall','-Wextra','-Wno-unused-parameter','-Wno-unused-variable','-pedantic',
            \'-I.', '-I./include/.', '-I../include/.'
        \]}

let g:neomake_fortran_gfortran_maker = {
            \ 'errorformat': '%-C %#,'.'%-C  %#%.%#,'.'%A%f:%l%[.:]%c:,'.
            \ '%Z%\m%\%%(Fatal %\)%\?%trror: %m,'.'%Z%tarning: %m,'.'%-G%.%#',
            \'args':['-fsyntax-only', '-cpp', '-Wall', '-Wextra',
            \'-I.', '-I./modules/.', '-I../modules/.'
        \],
        \}

let g:neomake_cpp_gcc_maker = {
            \'args':[
            \'-Os','-g',
            \'-Wall','-Wextra','-Wno-unused-parameter','-Wno-unused-variable','-pedantic',
            \'-I.', '-I./include/.', '-I../include/.'
        \]}
