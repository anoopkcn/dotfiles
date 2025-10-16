Print = function(v)
	print(vim.inspect(v))
	return v
end

-- Enable spell check for git commits
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us" -- Or your preferred language
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Temporary highlight indicator when yanking (copying) text",
	group = vim.api.nvim_create_augroup("custom-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
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
