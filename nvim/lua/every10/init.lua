local M = {}

local function place_signs(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.fn.sign_unplace("every10_group", { buffer = bufnr })

    local last = vim.api.nvim_buf_line_count(bufnr)

    for lnum = M.freq, last, M.freq do
        vim.fn.sign_place(
            lnum,
            "every10_group",
            "EveryTenLineMark",
            bufnr,
            { lnum = lnum }
        )
    end
end

local function create_autocmds()
    vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
        group = vim.api.nvim_create_augroup("every10_autocmds", { clear = true }),
        callback = function(args)
            place_signs(args.buf)
        end,
    })
end

function M.setup(opts)
    opts     = opts or {}

    M.symbol = opts.symbol or "-"
    M.freq   = opts.freq or 10
    M.texthl = opts.texthl or "LineNr"

    vim.fn.sign_define("EveryTenLineMark", {
        text = M.symbol,
        texthl = M.texthl,
    })

    create_autocmds()
end

return M
