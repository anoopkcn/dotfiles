local ok, showdelta  = pcall(require, "showdelta")
if ok then
    showdelta.setup({
        view = { style = "sign" },
        source = "git", --if none given it will use the file on the disc as source
    })
end
