local ok, statusline = pcall(require, "statusline")
if ok then
    statusline.setup({
        sections = {
            left = { 'mode', "spacer", 'vcs', "spacer", 'diagnostics' },
            -- right = { "cursor", "spacer", 'position', "spacer", 'filetype' }
            right = { "cursor", "spacer", 'position', "spacer", 'bufnr', "spacer", 'filetype' }
        }
    })
end
