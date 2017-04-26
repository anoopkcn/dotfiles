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

" Syntax highlighting
" -------------------
hi Comment              ctermfg=247         ctermbg=NONE        cterm=NONE
hi Function             ctermfg=NONE         ctermbg=NONE        cterm=bold
hi Statement            ctermfg=172         ctermbg=NONE        cterm=NONE
hi Constant             ctermfg=37          ctermbg=NONE        cterm=NONE
hi String               ctermfg=41          ctermbg=NONE        cterm=NONE
hi PreProc              ctermfg=33          ctermbg=NONE        cterm=NONE
hi Type                 ctermfg=28          ctermbg=NONE        cterm=NONE
hi Special              ctermfg=204         ctermbg=NONE        cterm=NONE
hi Error                ctermfg=196         ctermbg=NONE        cterm=NONE
hi Todo                 ctermfg=130         ctermbg=NONE        cterm=NONE


" Editor colors
"------------------
" hi Normal            ctermfg=15     ctermbg=NONE   cterm=NONE
" hi Visual            ctermfg=251    ctermbg=239    cterm=NONE
" hi Visualnos         ctermfg=251    ctermbg=236    cterm=NONE
" hi Search            ctermfg=1      ctermbg=110    cterm=NONE
" hi SpecialKey        ctermfg=117    ctermbg=NONE   cterm=NONE
" hi WarningMsg        ctermfg=131    ctermbg=15     cterm=bold
" hi ErrorMsg          ctermfg=131    ctermbg=NONE   cterm=NONE
" hi MoreMsg           ctermfg=11     ctermbg=NONE   cterm=NONE

hi LineNr               ctermfg=243         ctermbg=NONE        cterm=NONE
hi CursorLineNr         ctermfg=130         ctermbg=NONE        cterm=bold
hi StatusLine           ctermfg=231         ctermbg=241         cterm=NONE 
hi StatusLineNC         ctermfg=235         ctermbg=244         cterm=NONE
hi VertSplit            ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi SpecialKey           ctermfg=245         ctermbg=NONE        cterm=NONE      term=NONE

"special colors
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal

hi SpellBad         ctermfg=1       ctermbg=NONE       cterm=underline      term=standout       term=underline
hi SpellCap         ctermfg=green   ctermbg=NONE        cterm=underline     term=underline
hi SpellRare        ctermfg=NONE    ctermbg=NONE        cterm=underline     term=underline
hi SpellLocal       ctermfg=NONE    ctermbg=NONE        cterm=underline     term=underline

hi clear SignColumn

