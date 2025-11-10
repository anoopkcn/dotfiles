local M = {}

function M.setup()
	local ok_mason, mason = pcall(require, "mason")
	if ok_mason then
		mason.setup()
	end

	local ok_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
	if ok_lsp then
		mason_lspconfig.setup()
	end
end

return M
