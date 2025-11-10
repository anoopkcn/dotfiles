local M = {}

function M.setup()
    vim.keymap.set(
        "n",
        "<leader>gg",
        "<CMD>Git<CR>",
        { noremap = true, silent = true, desc = "Open Git interface" }
    )

    vim.keymap.set(
        "n",
        "<leader>gl",
        "<CMD>Git log<CR>",
        { noremap = true, silent = true, desc = "Git log" }
    )
end

return M
