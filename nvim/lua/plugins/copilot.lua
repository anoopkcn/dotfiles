local pack = require("custom.pack")

local M = {}

M.specs = {
    "https://github.com/github/copilot.vim",
}

pack.ensure_specs(M.specs)

function M.setup()
    local ok, copilot = pcall(require, "copilot")
    if not ok then
        return
    end

    ---@diagnostic disable-next-line: redundant-parameter
    copilot.setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
    })
end

return M
