local M = {}

M.specs = {"https://github.com/stevearc/oil.nvim"}

M.setup = function()
    local ok, oil = pcall(require, "oil")
    if ok then
        ---@diagnostic disable-next-line
        oil.setup({
            view_options = {
                show_hidden = true,
            },
        })
        vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end
end

return M
