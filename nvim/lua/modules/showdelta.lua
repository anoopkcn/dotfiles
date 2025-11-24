local ok, showdelta = pcall(require, "showdelta")
if ok then
    showdelta.setup({
        view = {
            style = "sign",
            signs = { add = '┃', change = '┃', delete = '_' },
        },
        source = "git",
    })
end
