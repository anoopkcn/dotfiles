local M = {}

local function ensure_tools()
    local server_config = require("plugins.servers")
    local definitions = server_config.definitions or {}
    local mason_aliases = server_config.mason_aliases or {}
    local extra_tools = server_config.extra_tools or {}

    local ensure_installed = {}
    for server_name in pairs(definitions) do
        table.insert(ensure_installed, mason_aliases[server_name] or server_name)
    end
    for _, tool in ipairs(extra_tools) do
        table.insert(ensure_installed, tool)
    end

    local ok_installer, installer = pcall(require, "mason-tool-installer")
    if ok_installer then
        installer.setup { ensure_installed = ensure_installed }
    else
        vim.notify("mason-tool-installer is not available", vim.log.levels.WARN)
    end
end

function M.setup()
    local ok_mason, mason = pcall(require, "mason")
    if ok_mason then
        mason.setup()
    end
    ensure_tools()
end

return M
