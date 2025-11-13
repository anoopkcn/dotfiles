local M = {}

M.specs = {
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
}

local function load_server_config()
    local ok, config = pcall(require, "plugins.servers")
    if not ok then
        vim.notify("plugins.servers is not available", vim.log.levels.WARN)
        return nil
    end
    return config
end

local function ensure_tools()
    local server_config = load_server_config()
    if not server_config then
        return
    end
    local definitions = server_config.definitions or {}
    local mason_aliases = server_config.mason_aliases or {}
    local extra_tools = server_config.extra_tools or {}

    local ensure_installed = {}
    local seen = {}
    local function add(tool)
        if not tool or tool == "" or seen[tool] then
            return
        end
        table.insert(ensure_installed, tool)
        seen[tool] = true
    end

    for server_name in pairs(definitions) do
        add(mason_aliases[server_name] or server_name)
    end
    for _, tool in ipairs(extra_tools) do
        add(tool)
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
