-- Rex configuration. Reload with `rex config reload`.

-- Project picker in a floating pane; see rex-sessionizer next to this file.
rex.action{
  name     = "sessionizer",
  title    = "Open Project Session...",
  keywords = "project sessionizer fzf",
  run      = function(ctx, args)
    local script = os.getenv("HOME") .. "/.config/rex/rex-sessionizer"
    local command = { script }
    if ctx.client_id then
      command = { script, "--client", ctx.client_id }
    end
    local _, err = rex.session.new_layer{
      bounds = { 0.25, 0.15, 0.5, 0.6 },
      focus  = true,
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        label   = "Sessions",
        options = { command = command },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("cmd+shift+o", "sessionizer")
