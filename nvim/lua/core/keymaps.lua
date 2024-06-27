-- since Space is the leader key do nothing
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>")

-- remove search highlight on escape
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>")

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
