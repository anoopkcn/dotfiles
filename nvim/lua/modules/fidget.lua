local M = {}
M.specs = { "https://github.com/j-hui/fidget.nvim" }
M.config = function()
    local ok, fidget = pcall(require, "fidget")
    if not ok then
        return
    end
    fidget.setup()
end
return M
