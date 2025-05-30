set background=dark

let g:colors_name = "defaultshade"
let colors_name   = "defaultshade"
let s:black       = { "gui": "#282c34", "cterm": "236" }
let s:white       = { "gui": "#dcdfe4", "cterm": "188" }
let s:comment_fg  = { "gui": "#505762", "cterm": "241" }
let s:cursor_line = { "gui": "#313640", "cterm": "237" }
let s:fg          = s:white
let s:bg          = s:black

function! s:h(group, fg, bg, attr)
  if type(a:fg) == type({})
    exec "hi " . a:group . " guifg=" . a:fg.gui . " ctermfg=" . a:fg.cterm
  else
    exec "hi " . a:group . " guifg=NONE cterm=NONE"
  endif
  if type(a:bg) == type({})
    exec "hi " . a:group . " guibg=" . a:bg.gui . " ctermbg=" . a:bg.cterm
  else
    exec "hi " . a:group . " guibg=NONE ctermbg=NONE"
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
  else
    exec "hi " . a:group . " gui=NONE cterm=NONE"
  endif
endfun

call s:h("Normal", s:fg, s:bg, "")
call s:h("StatusLine", s:fg, s:cursor_line, "")
call s:h("StatusLineNC", s:comment_fg, s:cursor_line, "")
call s:h("CursorColumn", "", s:cursor_line, "")
call s:h("CursorLine", "", s:cursor_line, "")


if has('nvim')
  call s:h("WinSeparator", s:comment_fg, "", "")
  call s:h("TelescopeBorder", s:comment_fg, "", "")
  call s:h("FloatBorder", s:comment_fg, "", "")
  call s:h("NormalFloat", s:fg, "", "")
endif
