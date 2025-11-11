local M = {}

local server_config = require("plugins.servers")
local servers = server_config.definitions

local function shared_capabilities()
    return vim.lsp.protocol.make_client_capabilities()
end

local function configure_servers()
    if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
        vim.notify("vim.lsp config helpers are not available in this build", vim.log.levels.ERROR)
        return
    end

    vim.lsp.config('*', {
        capabilities = shared_capabilities(),
    })

    for server_name, server_opts in pairs(servers) do
        vim.lsp.config(server_name, server_opts)
    end

    vim.lsp.enable(vim.tbl_keys(servers))
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

-- stop LSP from relying on semantic tokens, which are very slow in some servers
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

local function setup_lsp_autocmd()
    local group = vim.api.nvim_create_augroup("CustomLspAttach", { clear = true })
    vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(args)
            local client = client_from_args(args)
            disable_semantic_tokens(client)

            local bufnr = args.buf
            vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
            vim.api.nvim_set_option_value("completeopt", "menuone,noinsert,noselect", {})

            local map_opts = { buffer = bufnr, noremap = true, silent = true }
            vim.keymap.set("n", "K", function()
                vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
            end, map_opts)
            -- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
            -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
        end,
    })
end

function M.setup()
    configure_servers()
    setup_lsp_autocmd()
end

return M
