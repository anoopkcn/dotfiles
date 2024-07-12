# NeoVim setup

**Philosophy:**

- If you can't explain it, _you don't need it._
- If it becomes a chore to maintain, _you don't need it._
- If you have to lookup how it works more than once, _you don't need it._

## Requirements

- [NeoVim](https://neovim.io) (>= 0.10)
  - Editor you need. _One can edit without it but not as contentedly._

## Optional Requirements

- [Nerd Font](https://www.nerdfonts.com/)
  - Nerdfonts are used for icons. _Everything should work without it but not as pretty._
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
  - Ripgrep is used for searching in files, it is faster than the default grep. _Everything should work without it but not as fast._

## Folder Structure

```bash
.
├── README.md
├── init.lua
└── lua
    ├── core
    │   └── *.lua
    └── plugins
        └── *.lua
```

[lazy.nvim](https://github.com/folke/lazy.nvim.git) plugin is used as the package manager and it is initialised with the following in the `init.lua` file.

All plugin specific configurations are stored in the `lua/plugins` directory. All color/theme related configurations are stored in the `lua/colors` directory.

## NeoVim Plugins

<!--
copy the following line yy
r!rg "\[.*\]\(.*\)" | grep "\-\- \[.*\]\(.*\)" | awk -F'\-\-' ' {print "-" $NF}' | sort
execute copied command in the command mode :@"  OR :<ctrl-r>"
-->

- [autopairs](https://github.com/windwp/nvim-autopairs)
- [comment.nvim](https://github.com/numToStr/Comment.nvim) (add line/block comments easily)
- [conform.nvim](https://github.com/stevearc/conform.nvim)(auto-formatting)
- [copilot](https://github.com/zbirenbaum/copilot.lua)(ai auto-completion)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)(gutter signs for git)
- [lazy.nvim](https://github.com/folke/lazy.nvim.git) (**plugin manager**)
- [mason.nvim](https://github.com/williamboman/mason.nvim)(**language tools manager**)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (auto-completion)
- [nvm-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)(code highlighting)
- [oil.nvim](https://github.com/stevearc/oil.nvim)(file explorer)
- [surround](https://github.com/tpope/vim-surround)(surround motion for pairs)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)(multi purpose navigation)
- [trouble.nvim](https://github.com/folke/trouble.nvim)(better quick fix list)
- [vim-fugitive](https://github.com/tpope/vim-fugitive)(best git plugin)
- [vim-repeat](https://github.com/tpope/vim-repeat)(repeat motions with dot)
- [vim-surround](https://github.com/tpope/vim-surround)(surround text with pairs)
- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)(sensible `[` and `]` commands)

## Plugin configuration dependancy

- lspconfig + nvim-lsp-cmp
  - autocomplete plugin `nvim-cmp` is using lsp results for it's autocompletion
