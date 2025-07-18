local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

local function get_make_list_command()
	if vim.fn.executable("make") ~= 1 then
		vim.notify("Make executable not found in PATH", vim.log.levels.WARN)
		return nil
	end

	return [[
        grep -E '^[a-zA-Z0-9][a-zA-Z0-9_-]*:' Makefile 2>/dev/null |
        sed -E 's/:.*//' | grep -v -E '^[A-Z]+$'
    ]]
end

-- Executes the make list command and returns a table of targets.
local function get_make_targets()
	local command = get_make_list_command()
	if not command then return nil end

	local ok, result = pcall(vim.fn.systemlist, command)
	if not ok then
		vim.notify("Failed to extract make targets: " .. tostring(result), vim.log.levels.ERROR)
		return nil
	end

	local targets = {}
	for _, target in ipairs(result) do
		local trimmed = vim.trim(target)
		if trimmed ~= "" and
				not string.match(trimmed, "^/") and
				not string.match(trimmed, "^%-%-") then
			table.insert(targets, trimmed)
		end
	end

	return targets
end

-- Creates and displays the Telescope picker for Makefile targets.
local function make_picker(opts)
	opts = opts or {}

	local targets = get_make_targets()
	if not targets then return end

	if #targets == 0 then
		vim.notify("No make targets found in the current directory", vim.log.levels.INFO)
		return
	end

	pickers.new(opts, {
		prompt_title = "Makefile Targets",
		finder = finders.new_table {
			results = targets,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry,
					ordinal = entry
				}
			end,
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			-- Execute selected make target
			local function execute_make_target()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)

				if selection then
					local target = selection.value
					local escaped_target = vim.fn.shellescape(target)
					local command = string.format("make %s", escaped_target)

					-- Use terminal split with controlled height
					-- vim.cmd(string.format("botright 20split term://%s", command))
					vim.cmd(string.format("botright %dsplit term://%s", math.floor(vim.o.lines * 0.38), command))
					local term_buf = vim.api.nvim_get_current_buf()
					local timestamp_suffix = vim.fn.strftime("%FT%T") .. "." .. math.random(100, 999)
					local new_buffer_name = string.format("Output: %s [%s]", target, timestamp_suffix)

					-- Attempt to set the new unique buffer name
					local ok, err = pcall(vim.api.nvim_buf_set_name, term_buf, new_buffer_name)
					if not ok then
						vim.notify(
							string.format("Warning: Could not set terminal buffer name to '%s'. Error: %s", new_buffer_name,
								tostring(err)),
							vim.log.levels.WARN
						)
						-- The terminal will still open, just possibly with a generic name.
					end

					-- vim.api.nvim_buf_set_name(term_buf, "Make Output: " .. target)
					-- TODO: bufferwipe result in error probably due to the native fzf plugin(being so fast)
					-- vim.api.nvim_buf_set_option_value(term_buf, "bufhidden", "wipe", {})
					-- Add 'q' keymap to close the terminal window
					vim.api.nvim_buf_set_keymap(term_buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
					vim.cmd("startinsert")
				end
			end

			-- Map Enter key to execute the target in both insert and normal mode
			actions.select_default:replace(execute_make_target)
			map("i", "<CR>", execute_make_target)
			map("n", "<CR>", execute_make_target)

			return true
		end,
	}):find()
end

-- -- Setup function to be called from the Telescope configuration
function M.setup()
	vim.keymap.set('n', '<leader>fm', make_picker, { desc = '[F]ind [M]ake Target' })
end

return M
