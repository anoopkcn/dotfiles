setlocal winfixheight
if &cursorline
  setlocal cursorline
endif
if !&spell
  setlocal nospell
endif
setlocal nolist 
setlocal nowrap nofoldenable
setlocal foldcolumn=0 colorcolumn=0
