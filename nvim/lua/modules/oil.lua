local M = {}

M.specs = { "https://github.com/stevearc/oil.nvim" }

M.config = function()
    local ok, oil = pcall(require, "oil")
    if not ok then
        return
    end
    ---@diagnostic disable-next-line
    oil.setup({
        delete_to_trash = true,
        view_options = {
            show_hidden = true,
            natural_order = true,
        },
        confirmation = {
            border = "rounded",
        },
        keymaps = {
            ["<C-c>"] = false,
            ["q"] = "actions.close",
        },
    })
    vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
end

return M
