-- custom statusline configuration

local modes = {
	["n"] = "NORMAL",
	["no"] = "NORMAL",
	["v"] = "VISUAL",
	["V"] = "VISUAL_LINE",
	[""] = "VISUAL_BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT_LINE",
	[""] = "SELECT_BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["R"] = "REPLACE",
	["Rv"] = "VISUAL_REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM_EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MOAR",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}


local function mode()
	local current_mode = vim.api.nvim_get_mode().mode
	return string.format(" %s ", modes[current_mode]):upper()
end


local function update_mode_colors()
	local current_mode = vim.api.nvim_get_mode().mode
	local mode_color = "%#StatusLineAccent#"
	if current_mode == "n" then
		mode_color = "%#StatuslineAccent#"
	elseif current_mode == "i" or current_mode == "ic" then
		mode_color = "%#StatuslineInsertAccent#"
	elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
		mode_color = "%#StatuslineVisualAccent#"
	elseif current_mode == "R" then
		mode_color = "%#StatuslineReplaceAccent#"
	elseif current_mode == "c" then
		mode_color = "%#StatuslineCmdLineAccent#"
	elseif current_mode == "t" then
		mode_color = "%#StatuslineTerminalAccent#"
	end
	return mode_color
end


local function filepath()
	local fpath
	if vim.fn.bufname('%') == "" then
		fpath = vim.fn.getcwd()
		fpath = vim.fn.fnamemodify(fpath, ":~")
	else
		fpath = vim.fn.expand('%:p:h')
		fpath = vim.fn.fnamemodify(fpath, ":~:.")
	end

	if fpath == "" then
		return " "
	end

	return string.format(" %%<%s/", fpath)
end


local function filename()
	local fname = vim.fn.expand "%:t"
	if fname == "" then
		return ""
	end
	return fname .. "%m "
end


local function lsp()
	local count = {}
	local levels = {
		errors = "Error",
		warnings = "Warn",
		info = "Info",
		hints = "Hint",
	}

	for k, level in pairs(levels) do
		count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
	end

	local errors = ""
	local warnings = ""
	local hints = ""
	local info = ""

	if count["errors"] ~= 0 then
		errors = " E " .. count["errors"] .. " "
	end
	if count["warnings"] ~= 0 then
		warnings = " W " .. count["warnings"] .. " "
	end
	if count["hints"] ~= 0 then
		hints = " H " .. count["hints"] .. " "
	end
	if count["info"] ~= 0 then
		info = " I " .. count["info"] .. " "
	end

	return errors .. warnings .. hints .. info
end


local vcs = function()
	local git_info = vim.b.gitsigns_status_dict
	if not git_info or git_info.head == "" then
		return ""
	end
	local added = git_info.added and ("+" .. git_info.added .. " ") or ""
	local changed = git_info.changed and ("~" .. git_info.changed .. " ") or ""
	local removed = git_info.removed and ("-" .. git_info.removed .. " ") or ""
	if git_info.added == 0 then
		added = ""
	end
	if git_info.changed == 0 then
		changed = ""
	end
	if git_info.removed == 0 then
		removed = ""
	end
	return table.concat {
		" ",
		git_info.head,
		" ",
		added,
		changed,
		removed,
		" ",
	}
end


local function filetype()
	return string.format(" %s ", vim.bo.filetype):upper()
end


local function lineinfo()
	if vim.bo.filetype == "alpha" then
		return ""
	end
	return " %P %l:%c "
end


Statusline = {}

Statusline.active = function()
	return table.concat {
		"%#Statusline#",
		update_mode_colors(),
		mode(),
		-- "%#Normal# ",
		filepath(),
		filename(),
		lsp(),
		"%=",
		vcs(),
		filetype(),
		lineinfo(),
	}
end


function Statusline.inactive()
	return " %F"
end


vim.api.nvim_exec2([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  augroup END
]], {})
