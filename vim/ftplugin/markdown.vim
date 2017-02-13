"Markdown
au BufNewFile,BufRead *.md,*.markdown,*.mdown,*.mkd,*.mkdn,README.md  setf markdown
command! -nargs=* -complete=file Preview call plugin#functions#preview(<f-args>)

