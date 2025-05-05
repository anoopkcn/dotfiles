vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"

local lspkind = require "lspkind"
lspkind.init {
    symbol_map = {
        Copilot = "C",
    },
}

local cmp = require "cmp"

cmp.setup {
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
    },
    -- sorting = {
    --     priority_weight = 2,
    --     comparators = {
    --       -- Below is the default comparitor list and order for nvim-cmp
    --       cmp.config.compare.offset,
    --       -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
    --       cmp.config.compare.exact,
    --       cmp.config.compare.score,
    --       cmp.config.compare.recently_used,
    --       cmp.config.compare.locality,
    --       cmp.config.compare.kind,
    --       cmp.config.compare.sort_text,
    --       cmp.config.compare.length,
    --       cmp.config.compare.order,
    --     },
    --   },
    mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
        ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            },
            { "i", "c" }
        ),
    },
      -- window = {
      --   completion = cmp.config.window.bordered(),
      --   documentation = cmp.config.window.bordered(),
      -- },
}
