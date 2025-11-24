local ok, minidiff = pcall(require, "mini.diff")
if ok then
    minidiff.setup({
        view = {
            style = "sign",
            signs = { add = '┃', change = '┃', delete = '_' },
        }
    })

    vim.keymap.set("n", "<leader>fc", function()
        local hunks = minidiff.export("qf", { scope = "all" })
        if #hunks == 0 then
            vim.notify("No changes to show", vim.log.levels.INFO)
            return
        end
        vim.fn.setqflist(hunks)
        vim.cmd("copen")
    end, { desc = "Diff: Open quickfix with all hunks" })
end
