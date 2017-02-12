"YouCompleteMe
" let g:ycm_key_list_select_completion=[]
" let g:ycm_key_list_previous_completion=[]
let g:ycm_global_ycm_extra_conf = "~/.vim/plugin/ycm_conf.py"

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
" Additional YouCompleteMe config.
let g:ycm_complete_in_comments = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_seed_identifiers_with_syntax = 1

" Disable unhelpful semantic completions.
let g:ycm_filetype_specific_completion_to_disable = { 'c': 1, 'gitcommit': 1, 'haskell': 1, 'javascript': 1, 'ruby': 1 } 

let g:ycm_semantic_triggers = {'haskell': [ '.', '(', ',',  ', ' ]} 

" Same as default, but with "markdown" and "text" removed.
let g:ycm_filetype_blacklist = {'notes': 1, 'unite': 1, 'tagbar': 1, 'pandoc': 1, 'qf': 1, 'vimwiki': 1, 'infolog': 1, 'mail': 1}

