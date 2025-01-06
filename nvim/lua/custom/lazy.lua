-- Lazy plugin manager (https://github.com/folke/lazy.nvim.git)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup {
    spec = {
        { import = "plugins" },
        { "navarasu/onedark.nvim" },
        { "tpope/vim-fugitive" },
        { "tpope/vim-unimpaired" },
        { "tpope/vim-repeat" },
        { "tpope/vim-surround" },
        { "numToStr/Comment.nvim" },
    },
}
