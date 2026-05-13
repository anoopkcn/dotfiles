-- Minimal vim-surround replacement.
-- Mappings: ds<c>, cs<o><n>, ys<motion><c>, yss<c>, visual S<c>
-- Targets: pairs () [] {} <> (with b/B aliases) and quotes " ' `
-- Opening bracket variant inserts inner spaces, closing variant does not.

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

-- Use Vim's `va<char>` to locate an existing surround; returns
-- (start_row, start_col, end_row, end_col) with 1-indexed rows, 0-indexed
-- inclusive cols, or nil if no match.
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

    -- `va"` (and friends) may include surrounding whitespace. Trim so sc/ec
    -- point exactly at the open/close delimiters.
    local close = close_for[target]
    if close then
        local last = vim.api.nvim_buf_get_lines(0, er - 1, er, false)[1] or ""
        while ec >= 0 and last:sub(ec + 1, ec + 1) ~= close do
            ec = ec - 1
            if ec < 0 then return nil end
        end
        local first = vim.api.nvim_buf_get_lines(0, sr - 1, sr, false)[1] or ""
        local open = target
        while sc < #first and first:sub(sc + 1, sc + 1) ~= open do
            sc = sc + 1
        end
    end
    return sr, sc, er, ec
end

local function ds()
    local ch = read_char(); if not ch then return end
    local target = around_targets[ch]; if not target then return end
    local sr, sc, er, ec = around_range(target); if not sr then return end
    vim.api.nvim_buf_set_text(0, er - 1, ec, er - 1, ec + 1, {})
    vim.api.nvim_buf_set_text(0, sr - 1, sc, sr - 1, sc + 1, {})
end

local function cs()
    local old = read_char(); if not old then return end
    local target = around_targets[old]; if not target then return end
    local new = read_char(); if not new then return end
    local pair = insert_pairs[new]; if not pair then return end
    local sr, sc, er, ec = around_range(target); if not sr then return end
    vim.api.nvim_buf_set_text(0, er - 1, ec, er - 1, ec + 1, { pair[2] })
    vim.api.nvim_buf_set_text(0, sr - 1, sc, sr - 1, sc + 1, { pair[1] })
end

-- Track first vs. repeated invocation so `.` reuses the previous char
-- instead of blocking on `getcharstr()` again.
local pending = false
local last_char = nil

-- Operator function: invoked by `g@` after a motion completes.
function _G.__surround_op(motion_type)
    local ch
    if pending then
        ch = read_char()
        pending = false
        if not ch then return end
        last_char = ch
    else
        ch = last_char
    end
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
    -- Leave cursor at the inserted open delimiter so subsequent `w`/`.`
    -- behave like tpope's plugin.
    pcall(vim.api.nvim_win_set_cursor, 0, { sr, sc })
end

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
local opts = { noremap = true, silent = true }

map("n", "ds", ds, opts)
map("n", "cs", cs, opts)
map("n", "ys", function()
    pending = true
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@"
end, { noremap = true, silent = true, expr = true })
map("n", "yss", function()
    pending = true
    vim.o.operatorfunc = "v:lua.__surround_op"
    return "g@_"
end, { noremap = true, silent = true, expr = true })
map("x", "S", visual_S, opts)

return {}
