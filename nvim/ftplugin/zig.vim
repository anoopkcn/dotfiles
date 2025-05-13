setlocal errorformat=%f:%l:%c-%k:\ error:\ %m,%f:%l:%c:\ error:\ %m,%f:%l:%c-%k:\ warning:\ %m,%f:%l:%c:\ warning:\ %m,%f:%l:%c-%k:\ note:\ %m,%f:%l:%c:\ note:\ %m,%-G%.%#


" FOR LUA"
"vim.api.nvim_create_autocmd("FileType", {
"      pattern = "zig",
"      callback = function()
"        -- Use vim.bo instead of vim.opt for buffer-local setting
"        vim.bo.errorformat = table.concat({
"          "%f:%l:%c-%k: error: %m", -- Error with range
"          "%f:%l:%c: error: %m",   -- Error without range
"          "%f:%l:%c-%k: warning: %m", -- Warning with range
"          "%f:%l:%c: warning: %m", -- Warning without range
"          "%f:%l:%c-%k: note: %m", -- Note with range
"          "%f:%l:%c: note: %m",   -- Note without range
"          "%-G%.%#"               -- Ignore unmatched lines
"        }, ",")
"        -- Optional: Set the makeprg if you haven't already
"        -- vim.bo.makeprg = "zig build"
"      end,
"      desc = "Set errorformat and makeprg for Zig files"
"    })

