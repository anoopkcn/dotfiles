local M = {}

M.specs = { "https://github.com/github/copilot.vim" }

function M.setup()
    -- Prevent copilot.vim from registering its inline suggestion autocommands
    -- while keeping the LSP client alive for blink-copilot.
    vim.g.copilot_no_maps = true

    local group = vim.api.nvim_create_augroup("github_copilot", { clear = true })
    vim.api.nvim_create_autocmd({ "FileType", "BufUnload" }, {
        group = group,
        callback = function(args)
            local fn = vim.fn["copilot#On" .. args.event]
            if type(fn) == "function" then
                pcall(fn)
            end
        end,
    })

    pcall(vim.fn["copilot#OnFileType"])
end

return M
