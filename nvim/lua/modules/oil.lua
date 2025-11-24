local ok, oil = pcall(require, "oil")
if ok then
    oil.setup({
        default_file_explorer = true,
        delete_to_trash = true,
        columns = {
            "permissions",
            "size",
            "mtime",
        },
        view_options = {
            show_hidden = true,
            natural_order = true,
        },
        confirmation = {
            border = "rounded",
        },
        keymaps = {
            ["<C-c>"] = false,
            ["gq"] = "actions.close",
        },
    })
    vim.keymap.set("n", "<leader>fe", function() oil.open() end, { desc = "Open parent directory" })
end
