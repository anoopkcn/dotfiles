local M = {}

function M.setup()
    local ok_mason, mason = pcall(require, "mason")
    if ok_mason then
        mason.setup()
    end
end

return M
