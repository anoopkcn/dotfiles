-- Hyprland config (Lua, 0.55+) — replaces the old sway setup.
-- Each require() runs in its own scope: an error in one module pops a
-- notification but doesn't stop the others from loading.

require("conf/options")
require("conf/monitors")
require("conf/rules")
require("conf/autostart")
require("conf/binds")
require("conf/displays")
