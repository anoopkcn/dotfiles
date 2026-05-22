return {
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
}
