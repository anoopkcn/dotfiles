return {
    'neovim/nvim-lspconfig',

    opts = {
        servers = {
            -- lua_ls = {},
            zls = {}
        }
    },
    config = function(_, opts)
        local lspconfig = require('lspconfig')
        for server, config in pairs(opts.servers) do
            lspconfig[server].setup(config)
        end

        vim.keymap.set(
            'n', 'K', function()
                vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
            end
        )
    end
}
