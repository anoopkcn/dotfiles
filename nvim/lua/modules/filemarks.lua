local M = {}

function M.setup()
    local ok, filemarks = pcall(require, "filemarks")
    if not ok then
        return
    end

    filemarks.setup()
end

return M
