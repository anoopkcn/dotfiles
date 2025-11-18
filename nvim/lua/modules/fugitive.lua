local M = {}

M.specs = { "https://github.com/tpope/vim-fugitive" }

M.config = function()
    vim.keymap.set(
        "n",
        "<leader>gg",
        "<CMD>Git<CR>",
        { noremap = true, silent = true, desc = "Open Git interface" }
    )
    vim.keymap.set(
        "n",
        "<leader>gl",
        "<CMD>rightbelow vertical Git log<CR>",
        { noremap = true, silent = true, desc = "Git log" }
    )
end

return M
