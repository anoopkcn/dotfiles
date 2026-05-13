-- Bracket-pair keymaps in the spirit of tpope/vim-unimpaired.
-- Behaviour mirrors plugin/unimpaired.vim for:
--   ]q [q  quickfix nav (with zv)
--   ]b [b  buffer nav
--   ]<Space> [<Space>  insert blank lines
--   ]e [e  exchange line down/up (preserves cursor column)
-- Plus local additions:
--   ]x [x  diagnostic nav
-- All mappings honour [count] where it makes sense.

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "]q", function() vim.cmd(vim.v.count1 .. "cnext")     vim.cmd("normal! zv") end, opts)
map("n", "[q", function() vim.cmd(vim.v.count1 .. "cprevious") vim.cmd("normal! zv") end, opts)
map("n", "]b", function() vim.cmd(vim.v.count1 .. "bnext")     end, opts)
map("n", "[b", function() vim.cmd(vim.v.count1 .. "bprevious") end, opts)

map("n", "]x", function() vim.diagnostic.jump({ count = vim.v.count1 })  end, opts)
map("n", "[x", function() vim.diagnostic.jump({ count = -vim.v.count1 }) end, opts)

local function blanks(n)
    local out = {}
    for _ = 1, n do out[#out + 1] = "" end
    return out
end

map("n", "]<Space>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, blanks(vim.v.count1))
end, opts)

map("n", "[<Space>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_lines(0, row, row, false, blanks(vim.v.count1))
end, opts)

-- :move resets the cursor to column 1; m` + `` round-trips the column.
-- foldmethod is forced to manual around the move so folds don't rebuild mid-op.
local function exchange(direction)
    local count = vim.v.count1
    local old_fdm = vim.wo.foldmethod
    if old_fdm ~= "manual" then vim.wo.foldmethod = "manual" end
    vim.cmd("normal! m`")
    pcall(vim.cmd, direction == "down"
        and ("move +" .. count)
        or  ("move --" .. count))
    vim.cmd("normal! ``")
    if old_fdm ~= "manual" then vim.wo.foldmethod = old_fdm end
end

map("n", "]e", function() exchange("down") end, opts)
map("n", "[e", function() exchange("up")   end, opts)

return {}
