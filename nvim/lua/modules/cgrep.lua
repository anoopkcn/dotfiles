local M = {}

local function open_quickfix_when_results(match_count)
    if match_count == 0 then
        vim.notify("CGrep: no matches found.", vim.log.levels.INFO)
        return
    end

    vim.cmd("copen")
end

local function parse_vimgrep_line(line)
    local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
    if not filename then
        return nil
    end

    return {
        filename = filename,
        lnum = tonumber(lnum, 10),
        col = tonumber(col, 10),
        text = text,
    }
end

local function set_quickfix_from_lines(lines)
    local items = {}
    for _, line in ipairs(lines) do
        local entry = parse_vimgrep_line(line)
        if entry then
            table.insert(items, entry)
        end
    end
    vim.fn.setqflist({}, " ", { title = "CGrep (rg)", items = items })
    return #items
end

local function run_rg(fargs)
    local cmd = { "rg", "--vimgrep", "--smart-case", "--color=never" }
    vim.list_extend(cmd, fargs)
    local lines = vim.fn.systemlist(cmd)
    return lines, vim.v.shell_error
end


M.setup = function()
    vim.api.nvim_create_user_command("CGrep", function(opts)
        if vim.tbl_isempty(opts.fargs) then
            vim.notify("CGrep expects ripgrep arguments (pattern first).", vim.log.levels.WARN)
            return
        end

        local lines, status = run_rg(opts.fargs)
        if status > 1 then
            local message = table.concat(lines, "\n")
            vim.notify(message ~= "" and message or "CGrep: ripgrep failed.", vim.log.levels.ERROR)
            return
        end

        local count = set_quickfix_from_lines(lines)
        open_quickfix_when_results(count)
    end, {
        nargs = "+",
        complete = "file",
        desc = "Run ripgrep and open quickfix list with matches",
    })
    vim.keymap.set("n", "<leader>/", ":CGrep<Space>", { silent = false, desc = "CGrep" })
end

return M
