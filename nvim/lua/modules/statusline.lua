local ok, statusline = pcall(require, "statusline")
if ok then
    statusline.setup({
        sections = {
            left = { 'mode', "spacer", 'bufnr', "spacer", 'vcs' },
            -- right = { "cursor", "spacer", 'position', "spacer", 'filetype' }
            right = { 'diagnostics', "spacer", "cursor", "spacer", 'position', "spacer", 'filetype' }
        }
    })
end
