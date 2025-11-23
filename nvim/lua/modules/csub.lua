local ok, csub = pcall(require, "csub")
if ok then
    csub.setup()
    vim.keymap.set("n", "<leader>s", "<cmd>Csub!<cr>", { desc = "Csub with quickfix buffer replacement" })
end
