local ok, statusline = pcall(require, "statusline")
if ok then
    statusline.setup({
        sections = {
            left = { 'mode', 'filetype',  'vcs'},
            middle = { 'bufnr', 'filepath', 'filename' },
            right = { 'diagnostics', 'position' },
        }
    })
end
