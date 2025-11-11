vim.keymap.set("i", "<C-c>", "<Esc>",
    { noremap = true, silent = true, desc = "Exit insert mode" })

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>",
    { noremap = true, silent = true, desc = "Disable Space" })

vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>",
    { noremap = true, silent = true, desc = "Disable Ctrl-Space" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>",
    { noremap = true, silent = true, desc = "Clear search highlight" })

vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]],
    { noremap = true, silent = true, desc = "Paste from system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]],
    { noremap = true, silent = true, desc = "Yank to system clipboard" })

vim.keymap.set("n", "J", "mzJ`z",
    { noremap = true, silent = true, desc = "Join lines without moving cursor" })

vim.keymap.set("n", "<C-d>", "<C-d>zz",
    { noremap = true, silent = true, desc = "Scroll down and center" })

vim.keymap.set("n", "<C-u>", "<C-u>zz",
    { noremap = true, silent = true, desc = "Scroll up and center" })

vim.keymap.set("n", "n", "nzzzv",
    { noremap = true, silent = true, desc = "Search next and center" })

vim.keymap.set("n", "N", "Nzzzv",
    { noremap = true, silent = true, desc = "Search next and center" })

vim.keymap.set("n", "<leader><enter>", "!!zsh<CR>",
    { noremap = true, silent = true, desc = "Execute line in shell" })

vim.keymap.set("n", "<leader>e", ":Explore<CR>",
    { noremap = true, silent = true, desc = "Open file explorer" })

vim.keymap.set("n", "<leader>bd", vim.cmd.bd,
    { noremap = true, silent = true, desc = "Buffer delete" })

vim.keymap.set("n", "<leader>on", vim.cmd.only,
    { noremap = true, silent = true, desc = "Close other buffers" })

vim.keymap.set("n", "<leader>\\", ":rightbelow vsplit<CR>",
    { noremap = true, silent = true, desc = "Vertical split" })

vim.keymap.set("n", "<leader>-", ":rightbelow split<CR>",
    { noremap = true, silent = true, desc = "Horizontal split" })

vim.keymap.set("n", "<M-j>", "<CMD>cnext<CR>",
    { noremap = true, silent = true, desc = "Next item in quickfixlist" })

vim.keymap.set("n", "<M-k>", "<CMD>cprev<CR>",
    { noremap = true, silent = true, desc = "Prev item in quickfixlist" })

vim.keymap.set("n", "<leader>qq", ToggleQuickfixList,
    { noremap = true, silent = true, desc = "Toggle quickfixlist" })

vim.keymap.set("n", "<leader>tt", vim.diagnostic.setqflist,
    { noremap = true, silent = true, desc = "Open diagnostics in quickfixlist" })

vim.keymap.set("n", "]t", function() vim.diagnostic.jump({ count = 1 }) end,
    { noremap = true, silent = true, desc = "Next diagnostic" })

vim.keymap.set("n", "[t", function() vim.diagnostic.jump({ count = -1 }) end,
    { noremap = true, silent = true, desc = "Previous diagnostic" })

vim.keymap.set("n", "<leader>x", function() vim.diagnostic.open_float({ border = 'single' }) end,
    { noremap = true, silent = true, desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end,
    { noremap = true, silent = true, desc = "Format buffer" })

vim.keymap.set("n", "<leader>dl", ":edit DEVLOG.md<cr>",
    { noremap = true, silent = true, desc = "Open DEVLOG.md" })

vim.keymap.set("n", "<leader>'", function()
        local raw_timestamp = os.date("%FT%T")
        local timestamp_str = string.format("%s", raw_timestamp or "")
        vim.api.nvim_put({ timestamp_str }, "c", true, true)
    end,
    { noremap = true, silent = true, desc = "Insert current timestamp" })

vim.keymap.set("n", "<leader>U", function() vim.pack.update() end,
    { noremap = true, silent = true, desc = "Update plugins" })
