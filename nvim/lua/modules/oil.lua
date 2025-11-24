local ok, oil = pcall(require, "oil")
if ok then
    oil.setup({
        columns = {
            "permissions",
            "size",
            "mtime",
        },
    })
    vim.keymap.set("n", "<leader>fe", function() oil.open() end, { desc = "Open parent directory" })
end
