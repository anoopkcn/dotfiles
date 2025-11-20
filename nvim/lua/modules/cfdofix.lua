local M = {}

local function snapshot_bufs()
    local map = {}
    local infos = vim.fn.getbufinfo({ buflisted = 1 })
    for _, info in ipairs(infos) do
        map[info.bufnr] = true
    end
    return map
end

local function cleanup_new_buffers(before, force)
    local infos = vim.fn.getbufinfo({ buflisted = 1 })
    for _, info in ipairs(infos) do
        if not before[info.bufnr] then
            pcall(vim.api.nvim_buf_delete, info.bufnr, { force = force })
        end
    end
end

local function cfdo_with_cleanup(cmd, force)
    local before = snapshot_bufs()
    local full_cmd = "cfdo " .. cmd .. " | update"
    vim.cmd(full_cmd)
    cleanup_new_buffers(before, force)
end

function M.setup()
    vim.api.nvim_create_user_command("Cfdow", function(opts)
        if opts.args == "" then
            vim.notify("Cfdow: expected command to run", vim.log.levels.WARN)
            return
        end
        cfdo_with_cleanup(opts.args, opts.bang)
    end, {
        nargs = "+",
        bang = true,
        complete = "command",
        desc = "cfdo with automatic write/cleanup (! forces buffer delete)",
    })
end

return M
