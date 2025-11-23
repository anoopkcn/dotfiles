-- enable spell check for git commits
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "rmd" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_gb"
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

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_win_set_cursor(0, mark)
            vim.schedule(function()
                vim.cmd("normal! zz")
            end)
        end
    end,
})

-- custom LSP attach actions
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        client.server_capabilities.semanticTokensProvider = nil

        -- Copilot inline suggestions
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
            vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

            vim.keymap.set("i", "<Tab>", function()
                return vim.lsp.inline_completion.get() and "" or "<Tab>"
            end, {
                desc = "LSP: accept inline completion",
                buffer = bufnr,
                expr = true,
            })

            vim.keymap.set("i", "<C-G>", vim.lsp.inline_completion.select, {
                desc = "LSP: switch inline completion",
                buffer = bufnr,
            })
        end

        -- LSP autotriggered completion
        -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
        --     vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
        --     vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
        --     vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get)
        -- end

        local map_opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ max_height = 25, max_width = 100, border = "rounded" })
        end, map_opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
    end,
})
