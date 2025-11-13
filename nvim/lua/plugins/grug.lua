local M = {}

M.specs = {
    "https://github.com/MagicDuck/grug-far.nvim",
}

function M.setup()
    local ok_grug, grug = pcall(require, "grug-far")
    if not ok_grug then
        vim.notify("grug-far.nvim is not available", vim.log.levels.WARN)
        return
    end

    grug.setup({ windowCreationCommand = "rightbelow vsplit" })

    vim.keymap.set({ "n", "v" }, "<leader>sr", function()
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
            transient = true,
            prefills = {
                filesFilter = (ext and ext ~= "") and ("*." .. ext) or nil,
            },
        })
    end, { desc = "Search and replace (grug)" })

    vim.keymap.set("n", "<leader>sw", function()
        grug.open({
            transient = true,
            prefills = {
                search = vim.fn.expand("<cword>"),
            },
        })
    end, { desc = "Search word under cursor (grug)" })

    vim.keymap.set("n", "<leader>sf", function()
        grug.open({
            transient = true,
            prefills = {
                paths = vim.fn.expand("%"),
            },
        })
    end, { desc = "Search current file (grug)" })

    vim.keymap.set("v", "<leader>sv", function()
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.with_visual_selection({
            transient = true,
            prefills = {
                filesFilter = (ext and ext ~= "") and ("*." .. ext) or nil,
            },
        })
    end, { desc = "Search visual selection in matching files (grug)" })
end

return M
