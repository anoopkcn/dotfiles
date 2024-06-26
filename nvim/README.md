# NeoVim setup

Philosophy:

- If you can't explain it, *you don't need it.*
- If it becomes a chore to maintain, *you don't need it.*
- If you have to lookup how it works more than once, *you don't need it.*

## Requirements

- [NeoVim](https://neovim.io) (>= 0.10)
  - Editor you need. *One can edit without it but not as contentedly.*

## Optional Requirements

- [Nerd Font](https://www.nerdfonts.com/)
  - Nerdfonts are used for icons. *Everything should work without it but not as pretty.*
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
  - Ripgrep is used for searching in files, it is faster than the default grep. *Everything should work without it but not as fast.*

## Folder Structure

```bash
.
├── README.md
├── init.lua
└── lua
    ├── core
    │   └── *.lua
    ├── colors
    │   └── *.lua
    └── plugins
        └── *.lua
```

[lazy.nvim](https://github.com/folke/lazy.nvim.git) plugin is used as the package manager and it is initialised with the following in the `init.lua` file.

All plugin specific configurations are stored in the `lua/plugins` directory. All color/theme related configurations are stored in the `lua/colors` directory.

## NeoVim Plugins

- Manager Plugins:

  - [lazy.nvim](https://github.com/folke/lazy.nvim.git) (plugin manager)
  - [mason](https://github.com/williamboman/mason.nvim)(lsp, dap, linter, formatter manager)

- Auto-Plugins (Setup and hopefully Forget)

  - [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (auto-syntax highlighting)
  - [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (auto-language server protocol)
  - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (auto-complete)
  - [conforms.nvim](https://github.com/stevearc/conform.nvim) (auto-formatting)
  - [copilot.nvim](https://github.com/zbirenbaum/copilot.lua) (auto-ai-completion)
  - [gitsigns](https://github.com/lewis6991/gitsigns.nvim) (gutter git signs)

- Utility plugins:

  - File navigation

    - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (fuzzy finder)
    - [harpoon](https://github.com/ThePrimeagen/harpoon) (project navigation/ buffer management)
  
  - Utils

    - [sleuth](https://github.com/tpope/vim-sleuth)(trating tab respectfuly)
    - [surround](https://github.com/kylechui/nvim-surround) (surround text objects)
    - [unimpaired](https://github.com/tpope/vim-unimpaired) (pairs of mappings with `[` and `]` prepend)
    - [fugitive](https://github.com/tpope/vim-fugitive) (git integration)

  - Bug navigation

    - [trouble.nvim](https://github.com/folke/trouble.nvim) (quickfix list and location list)

- Theme plugins:

  - [github](https://github.com/projekt0n/github-nvim-theme) (colorscheme)

## Plugin configuration dependancy

- Trouble + Telescope
  - Trouble can recive telescope search results therefore this feature is activated
- lspconfig + nvim-lsp-cmp
  - autocomplete plugin `nvim-cmp` is using lsp results for it's autocompletion
