-- Local filemarks plugin bindings and commands.
local M = {}

function M.setup()
    local ok, filemarks = pcall(require, "filemarks")
    if not ok then
        return
    end

    filemarks.setup()

    vim.api.nvim_create_user_command("FilemarksAdd", function(opts)
        local key = opts.fargs[1]
        local target = opts.fargs[2]
        filemarks.add(key, target)
    end, {
        desc = "Add/update a persistent filemark",
        nargs = "*",
        complete = "file",
    })

    vim.api.nvim_create_user_command("FilemarksRemove", function(opts)
        local key = opts.fargs[1]
        filemarks.remove(key)
    end, {
        desc = "Remove a filemark from the current project",
        nargs = "?",
    })

    vim.api.nvim_create_user_command("FilemarksList", function()
        filemarks.list()
    end, {
        desc = "List filemarks for the current project",
    })

    vim.api.nvim_create_user_command("FilemarksOpen", function(opts)
        local key = opts.fargs[1]
        if not key then
            vim.notify("Filemarks: provide a key to open", vim.log.levels.WARN)
            return
        end
        filemarks.open(key)
    end, {
        desc = "Jump to the file referenced by a key",
        nargs = 1,
    })
end

return M
