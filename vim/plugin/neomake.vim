autocmd! BufWritePost * Neomake

let g:neomake_error_sign = {'texthl': 'NeomakeErrorSign', 'text': '❗'}
let g:neomake_warning_sign={'text': '⚠', 'texthl': 'NeomakeErrorMsg'}
let g:neomake_message_sign = {'texthl': 'NeomakeMessageSign', 'text': '¶'}
let g:neomake_info_sign = {'texthl': 'MyInfoMsg', 'text': '¡'}

let g:neomake_c_enabled_makers = ['gcc']
let g:neomake_cpp_enabled_makers = ['gcc']
let g:neomake_fortran_enabled_makers = ['gfortran']

let g:neomake_c_gcc_maker = {
            \'args':[
            \'-Os','-g',
            \'-pedantic','-I./include/.','-I../include/.',
            \'-Wall','-Wextra','-Wno-unused-parameter','-Wno-unused-variable'
            \]}

