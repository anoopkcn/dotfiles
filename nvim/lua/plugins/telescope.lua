return {
	'nvim-telescope/telescope.nvim',
	-- tag = '0.1.8',
	branch = 'master',
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require('telescope').setup({})

		local builtin = require('telescope.builtin')
		-- git(g) something(x) g<x>
		vim.keymap.set('n', '<leader>gf', builtin.git_files)
		vim.keymap.set('n', '<leader>gc', builtin.git_bcommits)
		vim.keymap.set('n', '<leader>gC', builtin.git_commits)
		vim.keymap.set('n', '<leader>gb', builtin.git_branches)
		vim.keymap.set('n', '<leader>gs', builtin.git_status)
		-- find(f) something(x) f<x>
		vim.keymap.set('n', '<leader>ff', builtin.find_files)
		vim.keymap.set('n', '<leader>fg', builtin.live_grep)
		vim.keymap.set('n', '<leader>fb', builtin.buffers)
		vim.keymap.set('n', '<leader>fh', builtin.help_tags)
		vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols)
		vim.keymap.set('n', '<leader>fS', builtin.lsp_workspace_symbols)
		vim.keymap.set('n', '<leader>fr', builtin.lsp_references)
		vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions)
		vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations)
		vim.keymap.set('n', '<leader>fm', '<cmd>Telescope make<cr>', { desc = 'Find/Run Make target' })

		vim.keymap.set('n', '<leader>fw', function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set('n', '<leader>fW', function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set('n', '<leader>/', function()
			local search_term = vim.fn.input("Grep > ")
			if search_term ~= "" then
				builtin.grep_string({ search = search_term })
			end
		end)

		local finders = require "telescope.finders"
    local pickers = require "telescope.pickers"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    -- Generates the shell command to list make targets.
    local function get_make_list_command()
      -- Updated awk filter: Added conditions to exclude $1 being "Makefile" or "GNUmakefile"
      local awk_filter = [[awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ { if ($1 !~ /^\./ && $1 != "Makefile" && $1 != "GNUmakefile") { print $1 } }']]
      if vim.fn.executable "make" then
        local command = "make -pRrq | " .. awk_filter .. " | sort -u"
        return command
      else
        vim.notify("Can't find `make`.", vim.log.levels.WARN)
        return nil
      end
    end

    -- Executes the make list command and returns a table of targets.
    local function get_make_targets()
      local command_str = get_make_list_command()
      if not command_str then
        return nil
      end
      local ok, result = pcall(vim.fn.systemlist, command_str)
      if not ok then
        vim.notify("Error executing make list command: " .. tostring(result), vim.log.levels.ERROR)
        return nil
      end
      if result == nil then
         vim.notify("Failed to get targets from make list command. Output was nil.", vim.log.levels.ERROR)
         return nil
      end
      local targets = {}
      for _, target in ipairs(result) do
        if target ~= "" then
          table.insert(targets, target)
        end
      end
      return targets
    end

    -- Creates and displays the Telescope picker for Makefile targets.
    local function make_picker()
      local targets = get_make_targets()
      if not targets then
        return
      end
      if #targets == 0 then
        vim.notify("No make targets found (using 'make -p').", vim.log.levels.INFO)
        return
      end

      pickers.new({}, {
        prompt_title = "Makefile Targets",
        finder = finders.new_table {
          results = targets,
          entry_maker = function(entry)
            return { value = entry, display = entry, ordinal = entry }
          end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          -- Action to execute the selected make target using :!
          local function execute_make_target()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr) -- Close telescope window first

            if selection then
              local target = selection.value
              local escaped_target = vim.fn.shellescape(target)
              -- Construct the command string like "make target"
              local command_to_run = string.format("make %s", escaped_target)

              -- Execute the command using :! which handles displaying full output
              vim.notify("Executing: ! " .. command_to_run, vim.log.levels.INFO) -- Optional notification
              vim.cmd("!" .. command_to_run)
              -- Neovim will display "Press ENTER or type command to continue" after the command finishes
            end
          end

          -- Map Enter key in insert and normal mode to execute the target
          actions.select_default:replace(execute_make_target)
          map("i", "<CR>", execute_make_target)
          map("n", "<CR>", execute_make_target)

          return true
        end,
      }):find()
    end

    vim.api.nvim_create_user_command( 'TelescopeMake', make_picker, { nargs = 0})
    vim.keymap.set('n', '<leader>fm', '<cmd>TelescopeMake<cr>', { desc = '[F]ind [M]ake Target' })
	end
}
