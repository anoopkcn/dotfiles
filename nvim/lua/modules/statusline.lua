local ok, statusline = pcall(require, "statusline")
if ok then
    statusline.setup({
        sections = {
            left = { 'mode', 'bufnr', 'filepath', 'filename', 'vcs' },
            right = { 'diagnostics', 'filetype', 'position' }
        }
    })
end
