local pack = require("custom.pack")

local M = {}

M.specs = {
    "https://github.com/nvim-mini/mini.diff",
}

pack.ensure_specs(M.specs)

function M.setup()
    local ok_minidiff, minidiff = pcall(require, "mini.diff")
    if ok_minidiff then
        minidiff.setup({
            view = {
                style = "sign",
                signs = { add = "░", change = "░", delete = "_" },
            }
        })
    end
end

return M
