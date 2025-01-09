vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- since Space is the leader key do nothing
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<C-Space>", "<Nop>")

-- search highlight on escape
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")

-- ctrl+c as escape
vim.keymap.set("i", "<C-c>", "<Esc>")

-- vrertical scroll half a page up and center it
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- vrertical scroll half a page down and center it
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- vertically move all the way to the end of the file and center it
vim.keymap.set("n", "G", "Gzz")

-- vertically move full page doen and center it
vim.keymap.set("n", "<C-f>", "<C-f>zz")

-- vertically move full page up and center it
vim.keymap.set("n", "<C-b>", "<C-b>zz")

-- go to the next search result and center it
vim.keymap.set("n", "n", "nzz")

-- go to the previous search result and center it
vim.keymap.set("n", "N", "Nzz")

-- navigate to splits using i,j,h,l
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

-- motion keys should also go to word wrap
vim.keymap.set("n", "j", [[v:count?'j': 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count?'k': 'gk']], { noremap = true, expr = true })

-- remove buffer from currect active buffers
vim.keymap.set("n", "<Leader>bd", vim.cmd.bd)
-- jump to previous and next buffer
vim.keymap.set("n", "<leader>bn", vim.cmd.bn)
vim.keymap.set("n", "<leader>bp", vim.cmd.bp)

-- keep cursor at the bottom of visual once yanked
vim.keymap.set("v", "y", "ygv")

-- escape terminal mode in term
vim.keymap.set("t",'<Esc>', [[<C-\><C-n>]])

-- netrw keybindings
vim.keymap.set("n", "<leader>p", vim.cmd.Hex)
