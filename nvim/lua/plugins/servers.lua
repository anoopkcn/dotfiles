local servers = {
    marksman = {
        cmd = { "marksman", "server" },
        filetypes = { "markdown" },
        root_markers = { ".marksman.toml", ".git" },
    },
    texlab = {
        cmd = { "texlab" },
        filetypes = { "tex", "bib" },
        root_markers = { "texlab.tex", ".latexmkrc", ".git" },
        settings = {
            texlab = {
                build = {
                    executable = "pdflatex",
                    args = { "-synctex=1", "-interaction=nonstopmode", "%f" },
                    onSave = true,
                },
                forwardSearch = {
                    executable = "zathura",
                    args = { "--synctex-forward", "%l:1:%f", "%p" },
                },
                latexFormatter = "latexindent",
            },
        },
    },
    zls = {
        cmd = { "zls" },
        filetypes = { "zig", "zir" },
        root_markers = { "zls.json", "build.zig", ".git" },
    },
    ruff = {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
    },
    lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim", "require" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                telemetry = { enable = false },
            },
        },
    },
    pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "basic",
                    reportMissingImports = "warning",
                    diagnosticSeverityOverrides = {
                        reportUnusedVariable = "none",
                        reportGeneralTypeIssues = "information",
                    },
                },
            },
        },
    },
}

local mason_aliases = {
    lua_ls = "lua-language-server",
}

local extra_tools = {
    "stylua",
}

return {
    definitions = servers,
    mason_aliases = mason_aliases,
    extra_tools = extra_tools,
}
