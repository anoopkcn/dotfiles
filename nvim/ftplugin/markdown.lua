local buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
        vim.bo[buf].spell = true
        vim.wo.spelllang = "en_gb"   -- spelllang is window-local
    end
end)
