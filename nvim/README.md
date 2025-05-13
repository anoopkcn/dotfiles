# NeoVim setup
- If it can't be explained, it needn't be used.

## Requirements

- [NeoVim](https://neovim.io) (>= 0.10)
  - Editor you need. _One can edit without it but not as contentedly._

## NeoVim Plugins
[lazy.nvim](https://github.com/folke/lazy.nvim.git) plugin is used as the package manager and it is initialised with the following in the `init.lua` file.

All plugin specific configurations are stored in the `lua/plugins` directory. All color/theme related configurations are stored in the `colors` directory.

<!--
copy the following line yy
r!rg "\[.*\]\(.*\)" | grep "\-\- \[.*\]\(.*\)" | awk -F'\-\-' ' {print "-" $NF}' | sort
execute copied command in the command mode :@"  OR :<ctrl-r>"
-->

- [lazy.nvim](https://github.com/folke/lazy.nvim.git) (**plugin manager**)
- [nvm-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)(code highlighting)
- [vim-fugitive](https://github.com/tpope/vim-fugitive)(best git plugin)
- [vim-repeat](https://github.com/tpope/vim-repeat)(repeat motions with dot)
- [vim-surround](https://github.com/tpope/vim-surround)(surround text with pairs)
- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)(sensible `[` and `]` commands)
- [comment.nvim](https://github.com/numToStr/Comment.nvim) (add line/block comments easily)

## Custom Plugins
- split_jump.lua
