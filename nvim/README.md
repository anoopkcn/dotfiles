# NeoVim setup

**Philosophy:**

- If you can't explain it, _you don't need it._
- If it becomes a chore to maintain, _you don't need it._
- If you have to lookup how it works more than once, _you don't need it._

## Requirements

- [NeoVim](https://neovim.io) (>= 0.10)
  - Editor you need. _One can edit without it but not as contentedly._

## Optional Requirements

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

- [lazy.nvim](https://github.com/folke/lazy.nvim.git) (**plugin manager**)
- [nvm-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)(code highlighting)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)(multi purpose navigation)
- [vim-fugitive](https://github.com/tpope/vim-fugitive)(best git plugin)
- [vim-repeat](https://github.com/tpope/vim-repeat)(repeat motions with dot)
- [vim-surround](https://github.com/tpope/vim-surround)(surround text with pairs)
- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)(sensible `[` and `]` commands)
- [comment.nvim](https://github.com/numToStr/Comment.nvim) (add line/block comments easily)


## Extra
For LSP
```lua
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		}
	},
	config = function()
		require("lspconfig").lua_ls.setup {}
		vim.keymap.set("n", "<leader>,", function() vim.lsp.buf.format() end)
	end
}
```
