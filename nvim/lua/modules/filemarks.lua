local ok, filemarks = pcall(require, "filemarks")
if ok then
    filemarks.setup()
    local function open_filemarks_list()
        vim.cmd("split")
        vim.cmd("FilemarksList")
    end
    vim.keymap.set("n", "<leader>l", open_filemarks_list,
        { noremap = true, silent = true, desc = "show file marks list" })
end
