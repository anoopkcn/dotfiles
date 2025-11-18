local M = {}

M.specs = { "https://github.com/ibhagwan/fzf-lua" }

M.config = function()
    local ok, fzf = pcall(require, "fzf-lua")
    if not ok then
        return
    end

    fzf.setup({
        defaults = { file_icons = false },
        winopts = {
            backdrop = 100,
            preview  = {
                scrollbar = false,
                hidden = true,
            },
        },
        keymap = {
            builtin = {
                ["<c-u>"] = "preview-page-up",
                ["<c-d>"] = "preview-page-down",
                ["<c-h>"] = "toggle-preview",
            },
            fzf = {
                ["ctrl-q"] = "select-all+accept",
            },
        },
    })

    vim.keymap.set("n", "<leader>ff", fzf.files)
    -- vim.keymap.set("n", "<leader>ff", fzf.global)
    vim.keymap.set("n", "<leader>fb", fzf.buffers)
    vim.keymap.set("n", "<leader>fg", fzf.live_grep)
    vim.keymap.set("n", "<leader>fr", fzf.resume)
    vim.keymap.set("n", "<leader>fe", fzf.builtin)
    vim.keymap.set("n", "<leader>fw", fzf.grep_cword)
    vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD)
    vim.keymap.set("n", "<leader>fh", fzf.helptags)
    -- vim.keymap.set("n", "<leader>fs", fzf.lsp_live_workspace_symbols)
    vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols)
    vim.keymap.set("n", "<leader>fj", fzf.jumps)
    -- vim.keymap.set("n", "<leader>fr", fzf.lsp_references)
    -- vim.keymap.set("n", "<leader>fd", fzf.lsp_definitions)
    -- vim.keymap.set("n", "<leader>fi", fzf.lsp_implementations)
    vim.keymap.set("n", "<leader>gt", fzf.git_worktrees)
    vim.keymap.set("n", "<leader>gb", fzf.git_branches)
    vim.keymap.set("n", "<leader>ql", fzf.quickfix_stack)
    vim.keymap.set("n", "<leader>z", fzf.spell_suggest)
end

return M
