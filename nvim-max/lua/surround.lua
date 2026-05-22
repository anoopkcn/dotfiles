-- Minimal vim-surround replacement.
-- Mappings: ds<c>, cs<o><n>, ys<motion><c>, yss<c>, visual S<c>
-- Targets: pairs () [] {} <> (with b/B aliases) and quotes " ' `
-- Opening bracket variant inserts inner spaces, closing variant does not.
-- `.` repeats ds, cs, and ys (all route through a single operatorfunc).

local insert_pairs = {
    ["("] = { "( ", " )" }, [")"] = { "(", ")" }, ["b"] = { "(", ")" },
    ["["] = { "[ ", " ]" }, ["]"] = { "[", "]" },
    ["{"] = { "{ ", " }" }, ["}"] = { "{", "}" }, ["B"] = { "{", "}" },
    ["<"] = { "< ", " >" }, [">"] = { "<", ">" },
    ['"'] = { '"', '"' },
    ["'"] = { "'", "'" },
    ["`"] = { "`", "`" },
}

local around_targets = {
    ["("] = "(", [")"] = "(", ["b"] = "(",
    ["["] = "[", ["]"] = "[",
    ["{"] = "{", ["}"] = "{", ["B"] = "{",
    ["<"] = "<", [">"] = "<",
    ['"'] = '"', ["'"] = "'", ["`"] = "`",
}

-- Closing delimiter for each text-object char. Used to trim trailing
-- whitespace that `va"` etc. may include in the selection.
local close_for = {
    ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">",
    ['"'] = '"', ["'"] = "'", ["`"] = "`",
}

local function read_char()
    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok or ch == "" or ch == "\27" then return nil end
    return ch
end

-- Use Vim's `va<char>` to locate an existing surround. Returns
-- (start_row, start_col, end_row, end_col) with 1-indexed rows, 0-indexed
-- inclusive cols, or nil if no match. Trims surrounding whitespace that
-- `va"` (and friends) sometimes include.
local function around_range(target)
    local view = vim.fn.winsaveview()
    local ok = pcall(vim.cmd, "silent! keepjumps normal! va" .. target)
    if not ok or not vim.fn.mode():match("[vV\22]") then
        vim.fn.winrestview(view)
        return nil
    end
    vim.cmd("normal! \27")
    local s = vim.api.nvim_buf_get_mark(0, "<")
    local e = vim.api.nvim_buf_get_mark(0, ">")
    local sr, sc, er, ec = s[1], s[2], e[1], e[2]
    local close = close_for[target]
    if close then
        local last = vim.api.nvim_buf_get_lines(0, er - 1, er, false)[1] or ""
        while ec >= 0 and last:sub(ec + 1, ec + 1) ~= close do
            ec = ec - 1
            if ec < 0 then return nil end
        end
        local first = vim.api.nvim_buf_get_lines(0, sr - 1, sr, false)[1] or ""
        while sc < #first and first:sub(sc + 1, sc + 1) ~= target do
            sc = sc + 1
        end
    end
    return sr, sc, er, ec
end

local function do_ds(ch)
    local target = ch and around_targets[ch]; if not target then return end
    local sr, sc, er, ec = around_range(target); if not sr then return end
    vim.api.nvim_buf_set_text(0, er - 1, ec, er - 1, ec + 1, {})
    vim.api.nvim_buf_set_text(0, sr - 1, sc, sr - 1, sc + 1, {})
end

local function do_cs(old, new)
    local target = old and around_targets[old]; if not target then return end
    local pair = new and insert_pairs[new]; if not pair then return end
    local sr, sc, er, ec = around_range(target); if not sr then return end
    vim.api.nvim_buf_set_text(0, er - 1, ec, er - 1, ec + 1, { pair[2] })
    vim.api.nvim_buf_set_text(0, sr - 1, sc, sr - 1, sc + 1, { pair[1] })
end

local function do_ys(ch, motion_type)
    local pair = ch and insert_pairs[ch]; if not pair then return end
    local s = vim.api.nvim_buf_get_mark(0, "[")
    local e = vim.api.nvim_buf_get_mark(0, "]")
    local sr, sc, er, ec = s[1], s[2], e[1], e[2]
    if motion_type == "line" then
        local first = vim.api.nvim_buf_get_lines(0, sr - 1, sr, false)[1] or ""
        local last  = vim.api.nvim_buf_get_lines(0, er - 1, er, false)[1] or ""
        local indent = first:find("%S")
        sc = indent and (indent - 1) or 0
        ec = #last - 1
    end
    if ec + 1 < 0 then return end
    vim.api.nvim_buf_set_text(0, er - 1, ec + 1, er - 1, ec + 1, { pair[2] })
    vim.api.nvim_buf_set_text(0, sr - 1, sc,     sr - 1, sc,     { pair[1] })
    pcall(vim.api.nvim_win_set_cursor, 0, { sr, sc })
end

-- Op dispatch.
-- `pending` is set by each mapping right before returning `g@...`. On the
-- first operatorfunc call, we read the user's char(s) and execute. On a
-- subsequent `.` (no mapping fired), `pending` is nil and we replay the
-- previous op with its saved chars.
local pending = nil
local last_op, last_ds, last_cs_old, last_cs_new, last_ys = nil, nil, nil, nil, nil

function _G.__surround_op(motion_type)
    local op = pending
    pending = nil

    if op == "ds" then
        local ch = read_char(); if not ch then return end
        last_ds = ch
        last_op = "ds"
        do_ds(ch)
    elseif op == "cs" then
        local old = read_char(); if not old then return end
        local new = read_char(); if not new then return end
        last_cs_old, last_cs_new = old, new
        last_op = "cs"
        do_cs(old, new)
    elseif op == "ys" then
        local ch = read_char(); if not ch then return end
        last_ys = ch
        last_op = "ys"
        do_ys(ch, motion_type)
    else
        if last_op == "ds" then
            do_ds(last_ds)
        elseif last_op == "cs" then
            do_cs(last_cs_old, last_cs_new)
        elseif last_op == "ys" then
            do_ys(last_ys, motion_type)
        end
    end
end

-- If the user aborts op-pending mode (e.g. `ys<Esc>`), operatorfunc never
-- fires and `pending` would otherwise stick around and poison the next `.`.
vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "no*:*",
    callback = function() pending = nil end,
})

local function visual_S()
    local ch = read_char(); if not ch then return end
    local pair = insert_pairs[ch]; if not pair then return end
    local mode = vim.fn.mode()
    vim.cmd("normal! \27")
    local s = vim.api.nvim_buf_get_mark(0, "<")
    local e = vim.api.nvim_buf_get_mark(0, ">")
    local sr, sc, er, ec = s[1], s[2], e[1], e[2]
    if mode == "V" then
        local first = vim.api.nvim_buf_get_lines(0, sr - 1, sr, false)[1] or ""
        local last  = vim.api.nvim_buf_get_lines(0, er - 1, er, false)[1] or ""
        local indent = first:find("%S")
        sc = indent and (indent - 1) or 0
        ec = #last - 1
    else
        local last = vim.api.nvim_buf_get_lines(0, er - 1, er, false)[1] or ""
        if ec >= #last then ec = #last - 1 end
    end
    vim.api.nvim_buf_set_text(0, er - 1, ec + 1, er - 1, ec + 1, { pair[2] })
    vim.api.nvim_buf_set_text(0, sr - 1, sc,     sr - 1, sc,     { pair[1] })
end

local map = vim.keymap.set
local expr_opts = { noremap = true, silent = true, expr = true }

map("n", "ds", function()
    pending = "ds"
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@l"
end, expr_opts)

map("n", "cs", function()
    pending = "cs"
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@l"
end, expr_opts)

map("n", "ys", function()
    pending = "ys"
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@"
end, expr_opts)

map("n", "yss", function()
    pending = "ys"
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@_"
end, expr_opts)

map("x", "S", visual_S, { noremap = true, silent = true })

return {}
