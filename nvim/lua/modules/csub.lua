local ok, csub = pcall(require, "csub")
if ok then
    csub.setup({ separator = "│" })
    vim.keymap.set("n", "<leader>s", "<cmd>Csub<cr>", { desc = "Open Csub buffer for current active quickfix list" })
end
