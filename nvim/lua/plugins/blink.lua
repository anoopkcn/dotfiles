return {
	'saghen/blink.cmp',
	dependencies = 'rafamadriz/friendly-snippets',
	version = '*',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = 'default' },
		sources = {
			default = { 'lsp', 'path', 'buffer', "codecompanion" },
			cmdline = {}
		},
	},
	opts_extend = { "sources.default" },
}
