local enabled = {}

-- Which LSPs should always run (all filetypes)
local always = {
    copilot = true,
}

-- Which LSPs should only run for specific filetypes
local ft_servers = {
    lua = { "lua_ls" },
    python = { "basedpyright" },
    markdown = { "marksman" },
}

vim.api.nvim_create_autocmd({ "FileType" }, {
    callback = function(args)
        local bufnr = args.buf
        local ft = vim.bo[bufnr].filetype

        if enabled[bufnr] then return end
        -- Check file size before enabling LSP
        local file = vim.api.nvim_buf_get_name(bufnr)
        if file ~= "" then            -- avoid checking unnamed buffers
            local size = vim.fn.getfsize(file)
            if size > 500 * 1024 then -- > 500KB
                enabled[bufnr] = true -- mark as handled
                return                -- skip LSP for large files
            end
        end
        enabled[bufnr] = true

        vim.defer_fn(function()
            local to_enable = {}

            for server in pairs(always) do
                to_enable[#to_enable + 1] = server
            end

            local fts = ft_servers[ft]
            if fts then
                for _, server in ipairs(fts) do
                    to_enable[#to_enable + 1] = server
                end
            end

            if #to_enable > 0 then
                vim.lsp.enable(to_enable)
            end
        end, 100)
    end,
})


local function get_client(args)
    return vim.lsp.get_client_by_id(args.data and args.data.client_id or args.client_id)
end

local function _disable_semantic_tokens(client)
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

local _group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = _group,
    callback = function(args)
        local client = get_client(args)
        _disable_semantic_tokens(client)

        local bufnr = args.buf
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
