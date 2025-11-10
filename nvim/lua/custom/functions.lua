Print = function(v)
	print(vim.inspect(v))
	return v
end

-- Enable spell check for git commits
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit,markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us" -- Or your preferred language
  end,
})

-- vim.api.nvim_create_autocmd("TextYankPost", {
-- 	desc = "Temporary highlight indicator when yanking (copying) text",
-- 	group = vim.api.nvim_create_augroup("custom-highlight-yank", { clear = true }),
-- 	callback = function()
-- 		vim.highlight.on_yank()
-- 	end,
-- })

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
	command = "wincmd =",
})

-- no auto continue comments on new line
-- vim.api.nvim_create_autocmd("FileType", {
-- 	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
-- 	callback = function()
-- 		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
-- 	end,
-- })

-- syntax highlighting for dotenv files
vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})

-- show cursorline only in active window enable
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

-- show cursorline only in active window disable
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = "active_cursorline",
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	desc = "Vim terminal configurations",
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

ToggleQuickfixList = function()
  local list_win_found = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      list_win_found = true
      break -- Exit loop once any list window is found
    end
  end

  if list_win_found then
    vim.cmd('cclose')
    vim.cmd('lclose')
  else
    vim.cmd('copen')
  end
end

function ShowDiagnostics()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })

	if vim.tbl_isempty(diagnostics) then
		vim.api.nvim_echo({ { '' } }, false, {})
		return
	end

	local message_chunks = {}
	local severity_highlights = {
		[vim.diagnostic.severity.ERROR] = "DiagnosticError",
		[vim.diagnostic.severity.WARN]  = "DiagnosticWarn",
		[vim.diagnostic.severity.INFO]  = "DiagnosticInfo",
		[vim.diagnostic.severity.HINT]  = "DiagnosticHint",
	}

	for i, diag in ipairs(diagnostics) do
		local hl_group = severity_highlights[diag.severity] or "MoreMsg"
		local message = string.format("[%s] %s", diag.source or "LSP", diag.message)
		table.insert(message_chunks, { message, hl_group })

		if i < #diagnostics then
			table.insert(message_chunks, { " | ", "NonText" })
		end
	end

	local available_width = math.max(0, vim.v.echospace - 14)
	local current_width = 0
	local truncated_chunks = {}
	local trunc_str = "…"
	local trunc_width = vim.fn.strwidth(trunc_str)

	for _, chunk in ipairs(message_chunks) do
		local chunk_text = chunk[1]
		local chunk_hl = chunk[2]
		local chunk_width = vim.fn.strwidth(chunk_text)

		if current_width + chunk_width < available_width then
			table.insert(truncated_chunks, chunk)
			current_width = current_width + chunk_width
		else
			local remaining_space = available_width - current_width
			if remaining_space > trunc_width then
				local new_width = remaining_space - trunc_width
				local truncated_text = vim.fn.strcharpart(chunk_text, 0, new_width)
				table.insert(truncated_chunks, { truncated_text, chunk_hl })
				table.insert(truncated_chunks, { trunc_str, 'WarningMsg' })
			end
			break
		end
	end

	vim.api.nvim_echo(truncated_chunks, false, {})
end

-- vim.api.nvim_create_autocmd('CursorMoved', {
-- 	pattern = '*',
-- 	callback = ShowDiagnostics,
-- })


