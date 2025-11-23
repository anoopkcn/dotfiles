local ok, csubstitute = pcall(require, "csub")
if ok then
    csubstitute.setup()
    vim.keymap.set("n", "<leader>s", "<cmd>Csub!<cr>", { desc = "Csub with quickfix buffer replacement" })
end
