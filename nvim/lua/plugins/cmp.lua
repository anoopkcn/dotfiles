return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter', 
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'onsails/lspkind.nvim',
  },
  config = function()
    local cmp = require('cmp')
    local lspkind = require('lspkind') 

    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end

    cmp.setup({
      -- == Window Appearance ==
      window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
      },
      -- == Key Mappings ==
      mapping = cmp.mapping.preset.insert({
        -- Select previous item
        ['<C-p>'] = cmp.mapping.select_prev_item(), -- Or <C-p>
        ['<Up>'] = cmp.mapping.select_prev_item(),
        -- Select next item
        ['<C-n>'] = cmp.mapping.select_next_item(), -- Or <C-n>
        ['<Down>'] = cmp.mapping.select_next_item(),
        -- Abort completion
        ['<C-e>'] = cmp.mapping.abort(),
        -- Accept selected suggestion
        ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }), 
      }),

      sources = cmp.config.sources({
        { name = 'nvim_lsp' },  -- LSP suggestions
        { name = 'buffer' },    -- Text from the current buffer
        -- { name = 'path' },      -- Filesystem paths
      }),

      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol',
          maxwidth = 10,   
          ellipsis_char = '...', 
        })
      },

       experimental = {
         ghost_text = true, -- Show completion preview inline (requires Neovim 0.10+)
       },
    })

  end,
}
