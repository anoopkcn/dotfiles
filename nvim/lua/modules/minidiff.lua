local M = {}

M.specs = { "https://github.com/nvim-mini/mini.diff" }

M.config = function()
    local ok, minidiff = pcall(require, "mini.diff")
    if ok then
        minidiff.setup({
            view = {
                style = "sign",
                signs = { add = "░", change = "░", delete = "░" },
            }
        })
    end
end

return M
