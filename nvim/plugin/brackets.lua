-- Bracket-pair keymaps in the spirit of tpope/vim-unimpaired, for what the
-- builtin unimpaired-style defaults (:h [q, :h [b, :h [<Space>, :h [d) lack:
--   ]q [q  quickfix nav that wraps around and opens folds (zv)
--   ]e [e  exchange line down/up (preserves cursor column)
-- All mappings honour [count].

local map = vim.keymap.set

local function with_desc(desc)
    return { silent = true, desc = desc }
end

local function qf_jump(forward)
    local step = forward and "cnext" or "cprevious"
    local wrap = forward and "cfirst" or "clast"
    if not pcall(vim.cmd, vim.v.count1 .. step) then
        pcall(vim.cmd, wrap)
    end
    vim.cmd("normal! zv")
end

map("n", "]q", function() qf_jump(true)  end, with_desc("Next quickfix item"))
map("n", "[q", function() qf_jump(false) end, with_desc("Previous quickfix item"))

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

map("n", "]e", function() exchange("down") end, with_desc("Exchange line below"))
map("n", "[e", function() exchange("up")   end, with_desc("Exchange line above"))
