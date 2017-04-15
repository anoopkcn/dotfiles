"-------lazy-----------
" Author: Anoop Chandran (strivetobelazy.com)
"
if version > 580
   hi clear
   if exists("syntax_on")
      syntax reset
   endif
endif

let g:colors_name = "lazy"
set t_Co=256
set background=dark

if version >= 700
    "TODO
endif

" General colors
" hi Normal         guifg=#f9f8ff   guibg=#000000   guisp=NONE      gui=NONE   ctermfg=15     ctermbg=NONE   cterm=NONE
hi Normal         guifg=#f9f8ff   guibg=#000000   guisp=NONE      gui=NONE   ctermfg=15     ctermbg=234   cterm=NONE
hi Cursor         guifg=NONE      guibg=#cd6f5c   guisp=#cd6f5c   gui=NONE   ctermfg=NONE   ctermbg=173    cterm=NONE
hi Visual         guifg=#c3c6ca   guibg=#554d4b   guisp=NONE      gui=NONE   ctermfg=251    ctermbg=239    cterm=NONE
hi Visualnos      guifg=#c3c6ca   guibg=#303030   guisp=NONE      gui=NONE   ctermfg=251    ctermbg=236    cterm=NONE
hi Search         guifg=#000000   guibg=#8dabcd   guisp=#8dabcd   gui=NONE   ctermfg=NONE   ctermbg=110    cterm=NONE
hi Folded         guifg=#857b6f   guibg=#000000   guisp=NONE      gui=NONE   ctermfg=241    ctermbg=233    cterm=NONE
hi StatusLineNC   guifg=NONE      guibg=#262626   guisp=#262626   gui=NONE   ctermfg=NONE   ctermbg=235    cterm=NONE
hi VertSplit      guifg=#444444   guibg=#444444   guisp=NONE      gui=NONE   ctermfg=238    ctermbg=238    cterm=NONE
hi StatusLineNC   guifg=#857b6f   guibg=#444444   guisp=NONE      gui=NONE   ctermfg=241    ctermbg=238    cterm=NONE
hi LineNr         guifg=#595959   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=240    ctermbg=NONE   cterm=NONE
hi SpecialKey     guifg=#87beeb   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=117    ctermbg=NONE   cterm=NONE
hi WarningMsg     guifg=#bd4848   guibg=#f9f8ff   guisp=#f9f8ff   gui=bold   ctermfg=131    ctermbg=15     cterm=bold
hi ErrorMsg       guifg=#bd5353   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=131    ctermbg=NONE   cterm=NONE
hi MoreMsg        guifg=#ffff00   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=11     ctermbg=NONE   cterm=NONE

" Diff highlighting
hi DiffAdd        guifg=NONE      guibg=#301430   guisp=#3c664e   gui=NONE   ctermfg=NONE   ctermbg=236    cterm=NONE
hi DiffDelete     guifg=#ad3838   guibg=#301430   guisp=#301430   gui=NONE   ctermfg=131    ctermbg=236    cterm=NONE
hi DiffChange     guifg=NONE      guibg=#7e8c2d   guisp=#331833   gui=NONE   ctermfg=NONE   ctermbg=238    cterm=NONE

" Syntax highlighting
hi Keyword        guifg=#d6d69a   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=186    ctermbg=NONE   cterm=NONE
hi Function       guifg=#bf9b76   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=137    ctermbg=NONE   cterm=bold
hi Constant       guifg=#44807d   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=66     ctermbg=NONE   cterm=NONE
hi Number         guifg=#386175   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=66     ctermbg=NONE   cterm=NONE
hi PreProc        guifg=#ad5234   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=131    ctermbg=NONE   cterm=NONE
hi Statement      guifg=#418db3   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=67     ctermbg=NONE   cterm=NONE
hi Identifier     guifg=#5f875f   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=65     ctermbg=NONE   cterm=bold
hi Type           guifg=#babaa2   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=144    ctermbg=NONE   cterm=NONE
hi Special        guifg=#7a490d   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=3      ctermbg=NONE   cterm=NONE
hi String         guifg=#7e8c2d   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=100    ctermbg=NONE   cterm=NONE
hi Comment        guifg=#576157   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=241    ctermbg=NONE   cterm=NONE
hi Todo           guifg=#a1481e   guibg=NONE      guisp=NONE      gui=NONE   ctermfg=130    ctermbg=NONE   cterm=NONE

"special colors
hi clear SpellBad
hi SpellBad term=standout ctermfg=1 term=underline cterm=underline
hi clear SpellCap
hi SpellCap term=underline cterm=underline ctermfg=green
hi clear SpellRare
hi SpellRare term=underline cterm=underline
hi clear SpellLocal
hi SpellLocal term=underline cterm=underline

hi clear SignColumn
hi LineNr ctermfg=237
hi Comment ctermfg=243

hi StatusLineNC ctermbg=237 ctermfg=235
hi StatusLine ctermbg=243 ctermfg=235
hi VertSplit cterm=NONE
hi SpecialKey  term=bold ctermfg=237
" hi Search cterm=NONE ctermfg=245 ctermbg=237
" hi visual cterm=NONE ctermfg=245 ctermbg=237

