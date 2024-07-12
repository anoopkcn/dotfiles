return {
	"huggingface/llm.nvim",
	enabled = false,
	dependencies = {
		"huggingface/llm-ls",
	},
	config = function()
		local llm = require("llm")
		llm.setup({
			api_token = "",
			model = "alias-code",
			backend = "openai",
			url = "https://helmholtz-blablador.fz-juelich.de:8000/v1",
		})
	end,
}
