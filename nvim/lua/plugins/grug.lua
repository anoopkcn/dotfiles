local pack = require("custom.pack")

local M = {}

M.specs = {
    "https://github.com/MagicDuck/grug-far.nvim",
}

pack.ensure_specs(M.specs)

function M.setup()
    local ok_grug, grug = pcall(require, "grug-far")
    if ok_grug then
        grug.setup({
            windowCreationCommand = "rightbelow vsplit",
        })
    end
    vim.keymap.set("n", "<leader>r", "<cmd>GrugFar<cr>", { desc = "Find in files with grug" })
end

return M
