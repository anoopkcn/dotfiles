-- Rex init
-- @anoopkcn

-- Session and project picker in the command palette. rex-sessionizer next to
-- this file lists the rows and opens the one picked.
local sessionizer = os.getenv("HOME") .. "/.config/rex/rex-sessionizer"

rex.action{
  name     = "sessionizer",
  title    = "Open Project Session...",
  keywords = "project session sessionizer switch",
  run      = function(ctx, args)
    -- Fast: other hosts' rows come from the cache that refresh keeps.
    local r, err = rex.exec({ sessionizer, "list", ctx.session_id or "" }, { timeout = 20 })
    if r == nil then error(err, 0) end
    if not r.ok then error("rex-sessionizer: " .. r.stderr, 0) end
    -- Detached, or Rex would stop it when the action returns.
    rex.exec.start({ sessionizer, "refresh" }, { detach = true })

    local key, why = rex.ui.pick{
      title       = "Open session",
      placeholder = "Filter sessions and projects",
      items       = rex.json.decode(r.stdout),
    }
    if key == nil then
      if why ~= "cancelled" then rex.log("warn", "sessionizer: " .. why) end
      return
    end

    local argv = { sessionizer, "open" }
    if ctx.client_id then
      table.insert(argv, "--client")
      table.insert(argv, ctx.client_id)
    end
    table.insert(argv, key)
    r, err = rex.exec(argv, { timeout = 20 })
    if r == nil then error(err, 0) end
    if not r.ok then error("rex-sessionizer: " .. r.stderr, 0) end
  end,
}

rex.bind("cmd+shift+o", "sessionizer")
