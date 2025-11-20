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
        highlight = {
            treesitter = true,
            lsp = false,
            load_buffers = false,
        },
        borders = {
            vert = " "
        }
    })
end
