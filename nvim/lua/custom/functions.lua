--  show diagnostics with custom signs
vim.diagnostic.config({
    signs = false,
    -- OR
    -- virtual_lines = true,
    -- OR
    -- virtual_lines = { current_line = true},
    -- OR
    -- signs = {
    --     text = {
    --         [vim.diagnostic.severity.ERROR] = "",
    --         [vim.diagnostic.severity.WARN] = "",
    --         [vim.diagnostic.severity.INFO] = "",
    --         [vim.diagnostic.severity.HINT] = "",
    --     }
    -- }
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
    command = "wincmd =",
})

-- Enable spell check for git commits
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
    end,
})

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    pattern = "*",
    desc = "highlight selection on yank",
    callback = function()
        vim.highlight.on_yank({ timeout = 200, visual = true })
    end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
            -- defer centering slightly so it's applied after render
            vim.schedule(function()
                vim.cmd("normal! zz")
            end)
        end
    end,
})

-- open help in vertical split
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "help",
--     command = "wincmd L",
-- })

-- no auto continue comments on new line
-- vim.api.nvim_create_autocmd("FileType", {
-- 	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
-- 	callback = function()
-- 		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
-- 	end,
-- })

-- syntax highlighting for dotenv files
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
    pattern = { ".env", ".env.*" },
    callback = function()
        vim.bo.filetype = "dosini"
    end,
})

-- show cursorline only in active window enable
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

-- show cursorline only in active window disable
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = "active_cursorline",
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Vim terminal configurations",
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

ToggleQuickfixList = function()
    local list_win_found = false
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            list_win_found = true
            break -- Exit loop once any list window is found
        end
    end

    if list_win_found then
        vim.cmd('cclose')
        vim.cmd('lclose')
    else
        vim.cmd('copen')
    end
end

local function client_from_args(args)
    if not args then
        return nil
    end
    local data = args.data or {}
    local client_id = data.client_id or args.client_id
    if not client_id then
        return nil
    end
    return vim.lsp.get_client_by_id(client_id)
end

local function disable_semantic_tokens(client)
    if not client then
        return
    end
    local provider = client.server_capabilities and client.server_capabilities.semanticTokensProvider
    if not provider then
        return
    end
    if provider.full or provider.range then
        client.server_capabilities.semanticTokensProvider = nil
    end
end


local group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
        local client = client_from_args(args)
        -- stop LSP from relying on semantic tokens, which are very slow in some servers
        disable_semantic_tokens(client)

        local bufnr = args.buf
        -- The following is replaced by blink.nvim
        -- if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
        --     vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
        --     vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        --     vim.keymap.set('i', '<C-Space>', function()
        --         vim.lsp.completion.get()
        --     end)
        -- end
        local map_opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
        end, map_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
    end,
})
