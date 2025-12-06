-- LICENSE: MIT
-- AUTHOR:  @anoopkcn

vim.g.mapleader = " "
vim.g.netrw_liststyle = 1
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 3
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "⤷ "
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.path:append("**")
vim.opt.swapfile = false
vim.opt.wildmenu = true
vim.opt.pumborder = "rounded"
vim.opt.splitkeep = "screen"
vim.opt.splitbelow = true
local text, background, dim = "#dcdfe4", "#22282f", "#3f444c"
vim.api.nvim_set_hl(0, "Normal", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "Pmenu", { fg = text, bg = background })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = text, bg = dim })
vim.api.nvim_set_hl(0, "PmenuBorder", { fg = dim, bg = background })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = dim, bg = background })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = dim})
vim.api.nvim_set_hl(0, "StatusLine", { bg = background })
require("keymaps")
require("autocmds")
require("packages")
-- vim.lsp.enable({ "clangd", "lua_ls", "pyright", "marksman", })
-- csub {
local ok, csub = pcall(require, "csub")
if ok then
    csub.setup({
        separator = "│",
        default_mode = nil,
        handlers = {
            { match = "FuzzyGrep",    mode = "replace" },
            { match = "vimgrep",      mode = "replace" },
            { match = "FuzzyBuffers", mode = "buffers" },
            { match = "FuzzyFiles",   mode = nil }, -- disabled
            { match = "make",         mode = nil }, -- disabled
        },
    })
    vim.keymap.set("n", "<leader>s", "<cmd>Csub<cr>", { desc = "Open Csub buffer for current active quickfix list" })
end
-- }

-- fuzzy {
local ok, fuzzy = pcall(require, "fuzzy")
if ok then
    fuzzy.setup()
    local function _fuzzy_grep(term, literal)
        term = vim.trim(term or "")
        if term == "" then
            return
        end
        local args = { term }
        if literal then
            table.insert(args, 1, "-F")
        end
        fuzzy.grep(args)
    end

    -- vim.keymap.set('n', ']q', '<CMD>FuzzyNext<CR>')
    -- vim.keymap.set('n', '[q', '<CMD>FuzzyPrev<CR>')

    vim.keymap.set("n", "<leader>/", ":Grep ",
        { silent = false, desc = "Fuzzy grep" })

    vim.keymap.set("n", "<leader>fg", "<cmd>GrepI<cr>",
        { silent = false, desc = "Fuzzy grep" })

    vim.keymap.set("n", "<leader>?", ":Files! --type f ",
        { silent = false, desc = "Fuzzy grep files" })

    vim.keymap.set("n", "<leader>ff", "<cmd>FilesI<cr>",
        { silent = false, desc = "Fuzzy grep files" })

    vim.keymap.set("n", "<leader>fb", ":Buffers! ",
        { silent = false, desc = "Fuzzy buffer list" })

    vim.keymap.set("n", "<leader>fw", function()
            _fuzzy_grep(vim.fn.expand("<cword>"), false)
        end,
        { silent = false, desc = "Fuzzy grep current word" })

    vim.keymap.set("n", "<leader>fW", function()
            _fuzzy_grep(vim.fn.expand("<cWORD>"), true)
        end,
        { silent = false, desc = "Fuzzy grep current WORD" })

    vim.keymap.set("n", "<leader>fl", "<CMD>FuzzyList<CR>",
        { silent = false, desc = "Fuzzy list" })
end
-- }

-- filemarks {
local ok, filemarks = pcall(require, "filemarks")
if ok then
    filemarks.setup({
        dir_open_cmd = "Explore"
        -- dir_open_cmd = "Oil %s"
    })
    local function open_filemarks_list()
        vim.cmd("split")
        vim.cmd("FilemarksList")
    end
    vim.keymap.set("n", "<leader>l", open_filemarks_list,
        { noremap = true, silent = true, desc = "show file marks list" })
end
-- }

-- fugitive {
vim.keymap.set("n", "<leader>G", "<CMD>rightbelow vertical Git<CR>",
    { noremap = true, silent = true, desc = "Open Git interface" }
)
vim.keymap.set("n", "<leader>gl", "<CMD>rightbelow vertical Git log<CR>",
    { noremap = true, silent = true, desc = "Git log" }
)
-- }

-- mini.diff {
local ok, minidiff = pcall(require, "mini.diff")
if ok then
    minidiff.setup({
        view = {
            style = "sign",
            signs = { add = '┃', change = '┃', delete = '_' },
        }
    })

    vim.keymap.set("n", "<leader>fc", function()
        local hunks = minidiff.export("qf", { scope = "all" })
        if #hunks == 0 then
            vim.notify("No changes to show", vim.log.levels.INFO)
            return
        end
        vim.fn.setqflist(hunks)
        vim.cmd("copen")
    end, { desc = "Diff: Open quickfix with all hunks" })
end
-- }

-- nvim-treesitter {
local ok, configs = pcall(require, "nvim-treesitter.configs")
if ok then
    configs.setup {
        ensure_installed = {
            "c", "cpp", "zig",
            "python", "bash", "lua",
            "vim", "vimdoc", "markdown",
            "toml", "yaml", "json", "xml", "html",
            -- "rust", "go", "fortran",
        },
        sync_install = false,
        auto_install = false,

        modules = {},
        ignore_install = {},

        highlight = {
            enable = true,
            disable = function(_, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok_stat and stats and stats.size > max_filesize then
                    return true
                end
            end,
            additional_vim_regex_highlighting = false,
        },
    }
end
-- }
