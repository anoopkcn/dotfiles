local uv = vim.uv or vim.loop
local M = {}

local state = {
	enabled = false,
	remote = nil,
	source = nil,
	job = nil,
}

local group = vim.api.nvim_create_augroup("custom-sync-autocmd", { clear = true })
local opts = vim.g.sync_config or {}

local function split_args(str)
	if not str or str == "" then
		return {}
	end
	local args = {}
	for arg in string.gmatch(str, "%S+") do
		table.insert(args, arg)
	end
	return args
end

local function build_command()
	local remote = state.remote or vim.g.sync_remote or opts.remote
	if not remote or remote == "" then
		return nil, "Remote target not set. Use :Sync on {user@host:path}"
	end

	local base_args = opts.args or vim.g.sync_args or { "-macviz" }
	local command = { "rsync" }
	for _, arg in ipairs(base_args) do
		table.insert(command, arg)
	end

	local exclude_file = opts.exclude_file or (vim.env.HOME .. "/.config/zsh/rsyncignore")
	if exclude_file and exclude_file ~= "" then
		local stat = uv.fs_stat(exclude_file)
		if stat then
			table.insert(command, ("--exclude-from=%s"):format(exclude_file))
		end
	end

	if opts.extra and type(opts.extra) == "string" then
		for _, arg in ipairs(split_args(opts.extra)) do
			table.insert(command, arg)
		end
	elseif opts.extra_args and type(opts.extra_args) == "table" then
		for _, arg in ipairs(opts.extra_args) do
			table.insert(command, arg)
		end
	end

	local source = state.source or vim.g.sync_source or opts.source or uv.cwd()
	if not source or source == "" then
		source = "."
	end

	table.insert(command, "./")
	table.insert(command, remote)

	return command, source, remote
end

local function reset_job()
	state.job = nil
end

local function notify(msg, level, opts)
	local severity = level or vim.log.levels.INFO
	local prefix_hl = "Identifier"
	local text_hl = "MoreMsg"

	if opts and opts.in_progress then
		prefix_hl = "Identifier"
		-- text_hl = "WarningMsg"
	elseif severity == vim.log.levels.ERROR then
		prefix_hl = "ErrorMsg"
		text_hl = "ErrorMsg"
	elseif severity == vim.log.levels.WARN then
		prefix_hl = "WarningMsg"
		text_hl = "WarningMsg"
	else
		prefix_hl = "DiffAdd"
		text_hl = "MoreMsg"
	end

	vim.schedule(function()
		vim.api.nvim_echo({
			{ "[Sync] ", prefix_hl },
			{ msg, text_hl },
		}, false, {})
		vim.cmd("redrawstatus")
	end)
end

local function run_sync(force)
	if not state.enabled and not force then
		return
	end

	if state.job then
		return
	end

	local command, cwd, remote = build_command()
	if not command then
		notify("Unable to run rsync: remote not configured", vim.log.levels.ERROR)
		return
	end

	notify(("syncing → %s"):format(remote), nil, { in_progress = true })

	state.job = vim.fn.jobstart(command, {
		cwd = cwd,
		on_stderr = function(_, data)
			if not data then
				return
			end
			local message = table.concat(vim.tbl_filter(function(line)
				return line ~= ""
			end, data), "\n")
			if message ~= "" then
				notify(message, vim.log.levels.ERROR)
			end
		end,
		on_exit = function(_, code)
			if code ~= 0 then
				notify(("rsync exited with code %d"):format(code), vim.log.levels.ERROR)
			else
				notify(("synced ← %s"):format(remote))
			end
			reset_job()
		end,
	})

	if state.job <= 0 then
		reset_job()
		notify("Failed to start rsync job", vim.log.levels.ERROR)
	end
end

local function should_sync(buf)
	if vim.bo[buf].buftype ~= "" then
		return false
	end

	if vim.bo[buf].modifiable == false then
		return false
	end

	return true
end

local function ensure_autocmd()
	vim.api.nvim_clear_autocmds({ group = group })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(args)
			if should_sync(args.buf) then
				run_sync()
			end
		end,
	})
end

function M.enable(remote)
	if remote and remote ~= "" then
		state.remote = remote
		vim.g.sync_remote = remote
	end

	local command = build_command()
	if not command then
		return notify("Remote not set. Provide target with `:Sync on {remote}`", vim.log.levels.ERROR)
	end

	state.enabled = true
	state.source = vim.g.sync_source or opts.source or uv.cwd()
	ensure_autocmd()
	notify("enabled")
	run_sync()
end

function M.disable()
	if not state.enabled then
		return
	end
	state.enabled = false
	vim.api.nvim_clear_autocmds({ group = group })
	if state.job then
		if state.job > 0 then
			pcall(vim.fn.jobstop, state.job)
		end
		reset_job()
	end
	notify("disabled")
end

function M.status()
	local remote = state.remote or vim.g.sync_remote or opts.remote or "unset"
	local enabled = state.enabled and "on" or "off"
	notify(("status: %s → %s"):format(enabled, remote))
end

function M.run_now()
	run_sync(true)
end

function M.handle_command(opts_table)
	local action = (opts_table.fargs[1] or ""):lower()
	if action == "on" then
		local remote = table.concat(opts_table.fargs, " ", 2)
		return M.enable(remote)
	elseif action == "off" then
		return M.disable()
	elseif action == "now" then
		return M.run_now()
	elseif action == "status" then
		return M.status()
	end

	notify("Usage: :Sync on {remote} | :Sync off | :Sync status | :Sync now", vim.log.levels.WARN)
end

return M
