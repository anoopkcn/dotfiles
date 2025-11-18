local M = {}

M.specs = { "https://github.com/stevearc/quicker.nvim" }

M.config = function()
    local ok, quicker = pcall(require, "quicker")
    if ok then
        ---@diagnostic disable-next-line
        quicker.setup({
            opts = {
                buflisted = false,
                number = true,
                relativenumber = true,
                signcolumn = "auto",
                winfixheight = false,
                wrap = false,
            },
            borders = {
                vert = " "
            }
        })
    end
end

return M
