return {
    'neovim/nvim-lspconfig',
    -- dependencies = { 'saghen/blink.cmp' },

    opts = {
        servers = {
            -- lua_ls = {},
            zls = {}
        }
    },
    config = function(_, opts)
        local lspconfig = require('lspconfig')
        for server, config in pairs(opts.servers) do
            -- config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
            lspconfig[server].setup(config)
        end

        vim.keymap.set(
            'n', 'K', function()
                vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
            end
        )
    end
}
