local ok, statusline = pcall(require, "statusline")
if ok then
    statusline.setup({
        sections = {
            left = { 'mode', 'bufnr', "spacer", 'vcs' },
            right = { 'diagnostics', "spacer", "cursor", "spacer", 'position', "spacer", 'filetype' }
        }
    })
end
