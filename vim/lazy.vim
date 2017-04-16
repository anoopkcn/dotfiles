"-------lazy-----------

if version > 580
   hi clear
   if exists("syntax_on")
      syntax reset
   endif
endif

let g:colors_name = "lazy"
set t_Co=256

if version >= 700
    "TODO
endif

hi Normal            ctermfg=15     ctermbg=NONE   cterm=NONE
hi Visual            ctermfg=251    ctermbg=239    cterm=NONE
hi Visualnos         ctermfg=251    ctermbg=236    cterm=NONE
hi Search            ctermfg=1      ctermbg=110    cterm=NONE
hi SpecialKey        ctermfg=117    ctermbg=NONE   cterm=NONE
hi WarningMsg        ctermfg=131    ctermbg=15     cterm=bold
hi ErrorMsg          ctermfg=131    ctermbg=NONE   cterm=NONE
hi MoreMsg           ctermfg=11     ctermbg=NONE   cterm=NONE

" Syntax highlighting
hi Function       ctermfg=137    ctermbg=NONE   cterm=bold
hi Todo           ctermfg=130    ctermbg=NONE   cterm=NONE

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
hi LineNr ctermfg=243  ctermbg=NONE cterm=NONE
hi Comment ctermfg=243 ctermbg=NONE cterm=NONE

hi StatusLineNC ctermbg=244 ctermfg=235 cterm=NONE
hi VertSplit cterm=NONE
hi SpecialKey  term=bold ctermfg=237 cterm=NONE

