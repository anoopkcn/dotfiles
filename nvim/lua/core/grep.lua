local function grepprg()
    if vim.o.grepprg ~= "" then
        return vim.o.grepprg
    end

    return "rg --vimgrep --smart-case"
end

local function build_command(args)
    local query = vim.fn.expandcmd(table.concat(args, " "))
    local program = grepprg()

    if query == "" then
        return program
    end

    return string.format("%s %s", program, query)
end

local function run_grep(use_loclist, args)
    local command = build_command(args)
    local lines = vim.fn.systemlist(command)
    local opts = { title = command, lines = lines }

    if use_loclist then
        vim.fn.setloclist(0, {}, "r", opts)
        vim.cmd("lwindow")
    else
        vim.fn.setqflist({}, "r", opts)
        vim.cmd("cwindow")
    end
end

vim.api.nvim_create_user_command("Grep", function(opts)
    run_grep(false, opts.fargs)
end, { nargs = "+", complete = "file_in_path" })

vim.api.nvim_create_user_command("LGrep", function(opts)
    run_grep(true, opts.fargs)
end, { nargs = "+", complete = "file_in_path" })

vim.cmd([[cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep']])
vim.cmd([[cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep']])

local quickfix_group = vim.api.nvim_create_augroup("quickfix", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = quickfix_group,
    pattern = "cgetexpr",
    command = "cwindow",
})
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    group = quickfix_group,
    pattern = "lgetexpr",
    command = "lwindow",
})

vim.keymap.set("n", "<leader>/", ":Grep<Space>", { silent = false, desc = "Grep" })
