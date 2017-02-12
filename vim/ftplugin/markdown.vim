"Markdown
autocmd BufNewFile,BufReadPost *.md,*.txt,*.html call plugin#functions#plaintext()
au BufNewFile,BufRead *.md,*.markdown,*.mdown,*.mkd,*.mkdn,README.md  setf markdown
command! -nargs=* -complete=file Preview call plugin#functions#preview(<f-args>)

