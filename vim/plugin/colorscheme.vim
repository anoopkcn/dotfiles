" Theme Settings"
if has('gui_running')
    set guioptions-=r
    set guioptions-=L
else
    set encoding=utf-8  "UTF-8 encoding to show certain characters
    set t_Co=256  " Setting terminal to 256 color scheme
    " set background=dark
    "let g:gruvbox_italic=1
    "let g:gruvbox_italicize_comments=1
    "let g:gruvbox_italicize_strings=1
    "let g:gruvbox_hls_cursor='fg4'
    "let g:gruvbox_sign_column='bg0'
    "let g:gruvbox_vert_split='bg0'
    " colorscheme gruvbox
    set background=light
    colorscheme PaperColor
    highlight clear SpellBad
    highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
    highlight clear SpellCap
    highlight SpellCap term=underline cterm=underline
    highlight clear SpellRare
    highlight SpellRare term=underline cterm=underline
    highlight clear SpellLocal
    highlight SpellLocal term=underline cterm=underline
endif

