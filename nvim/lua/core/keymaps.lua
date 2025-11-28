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

ToggleQuickfixList = function()
    local qf = vim.fn.getqflist({ winid = 1 }).winid
    if qf > 0 then vim.cmd("cclose") else vim.cmd("copen") end
end

vim.keymap.set("n", "<leader>fq", ToggleQuickfixList,
    { noremap = true, silent = true, desc = "Toggle quickfixlist" })

vim.keymap.set("n", "<leader>ft", vim.diagnostic.setqflist,
    { noremap = true, silent = true, desc = "Open diagnostics in quickfixlist" })

vim.keymap.set("n", "]t", function() vim.diagnostic.jump({ count = 1 }) end,
    { noremap = true, silent = true, desc = "Next diagnostic" })

vim.keymap.set("n", "[t", function() vim.diagnostic.jump({ count = -1 }) end,
    { noremap = true, silent = true, desc = "Previous diagnostic" })

vim.keymap.set("n", "<leader>x", function() vim.diagnostic.open_float({ border = 'single' }) end,
    { noremap = true, silent = true, desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format({ async = true }) end,
    { noremap = true, silent = true, desc = "Format buffer" })

TimestampInsert = function()
    local raw_timestamp = os.date("%FT%T")
    local timestamp_str = string.format("%s", raw_timestamp or "")
    vim.api.nvim_put({ timestamp_str }, "c", true, true)
end

vim.keymap.set("n", "<leader>'", TimestampInsert,
    { noremap = true, silent = true, desc = "Insert current timestamp" })

vim.keymap.set("n", "<leader>z", ":!", { desc = "Execute external command" })

-- move_lines.lua (single file)

-- Execute a :move command while preserving fold state
-- Execute a :move command while preserving fold state
local function exec_move(cmd)
    local old_fdm = vim.wo.foldmethod
    if old_fdm ~= "manual" then
        vim.wo.foldmethod = "manual"
    end

    vim.cmd("normal! m`")         -- save cursor position
    vim.cmd("silent! " .. cmd)    -- execute movement
    vim.cmd("normal! ``")         -- restore cursor

    if old_fdm ~= "manual" then
        vim.wo.foldmethod = old_fdm
    end
end

-- Move a single line up or down (normal mode)
local function move_line(direction)
    local count = vim.v.count1
    if direction == "up" then
        exec_move("move --" .. count)
    else
        exec_move("move +" .. count)
    end
end

-- Move a selected block up or down (visual mode)
local function move_visual(direction)
    local count = vim.v.count1

    -- Reselect visual area because Lua mappings exit visual mode
    vim.cmd("normal! gv")

    if direction == "up" then
        exec_move("'<,'>move '<--" .. count)
    else
        exec_move("'<,'>move '>+" .. count)
    end

    -- Restore visual selection after move
    vim.cmd("normal! gv")
end

-- Keymaps (normal & visual)
vim.keymap.set("n", "[e", function() move_line("up") end, { silent = true })
vim.keymap.set("n", "]e", function() move_line("down") end, { silent = true })
vim.keymap.set("x", "[e", function() move_visual("up") end, { silent = true })
vim.keymap.set("x", "]e", function() move_visual("down") end, { silent = true })

-- Cursor-preserving version of p and P
local function paste_preserve(which)
    local orig_pos = vim.api.nvim_win_get_cursor(0)

    if which == "p" then
        vim.cmd("normal! p")
    else
        vim.cmd("normal! P")
    end

    vim.api.nvim_win_set_cursor(0, orig_pos)
end

vim.keymap.set("n", "p", function()
    paste_preserve("p")
end, { silent = true })

vim.keymap.set("n", "P", function()
    paste_preserve("P")
end, { silent = true })
