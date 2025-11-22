local ok, csubstitute = pcall(require, "csubstitute")
if ok then
    csubstitute.setup()
    vim.keymap.set("n", "<leader>s", "<cmd>Csub!<cr>", { desc = "CSubstitute with quickfix buffer replacement" })
end
