-- Session and project picker for the command palette, a Rex take on the
-- tmux-sessionizer idea: it lists open sessions and project folders on this
-- machine and on the hosts in `rex hosts`, and switches the Rex app to the one
-- picked. init.lua loads it with require("sessionizer").
--
-- The action runs inside the Rex server and uses its Lua API, so listing
-- starts one process (find) and switching to a row on this machine starts
-- none. An action can't count on reaching other hosts (rex.servers() is empty
-- when the CLI runs it), so their rows are listed and opened by running this
-- file as a script with the CLI, which can.
--
--   rex do sessionizer                    pick a row in the app
--   rex do sessionizer key=KEY            open the row with id KEY
--   rex do sessionizer list=true --json   print the rows and their ids

local terminal = "com.superlogical.terminal"
local home = os.getenv("HOME")
local script = debug.getinfo(1, "S").source:gsub("^@", "")

-- The CLI. On macOS the server's PATH lacks it, and it ships inside the
-- server app.
local cli = home .. "/Library/Application Support/com.superlogical.rex/RexServer"
  .. "/Versions/Current/Rex Server.app/Contents/MacOS/rex"
do
  local f = io.open(cli)
  if f then f:close() else cli = "rex" end
end

-- Every directory directly under a root is a candidate project; nothing deeper
-- is searched. To list the folders inside a grouping folder, add it as a root.
-- Roots are relative to the home directory, on this machine and on each host.
local roots = {
  "develop", "develop/thirdparty", "develop/agents-on-hpc",
  "work", "Dropbox", "Dropbox/projects",
}

-- Other hosts' rows are shown from this file, since a host that is down would
-- hold the palette up for its whole timeout. The action starts a script that
-- rewrites it after each list. This machine's rows are always fetched fresh.
local cache = (os.getenv("XDG_CACHE_HOME") or home .. "/.cache") .. "/rex-sessionizer"
local cache_file = cache .. "/remote.json"

-- "akc@idli" -> "Idli": the name shown beside a host's rows.
local function host_name(label)
  local n = label:gsub("^.*@", ""):gsub("%..*$", "")
  return n:sub(1, 1):upper() .. n:sub(2)
end

local this_name
local function local_name()
  if this_name == nil then
    local r = rex.exec{ "uname", "-n" }
    this_name = host_name(r and r.ok and r.stdout:gsub("%s+$", "") or "local")
  end
  return this_name
end

local function terminal_block(view)
  for _, w in ipairs(view.windows or {}) do
    for _, layer in ipairs(w.layers or {}) do
      for _, b in ipairs(layer.blocks or {}) do
        if b.creator_name == terminal then return b.block_id end
      end
    end
  end
end

-- The open sessions of the server behind api (rex, or a rex.server table) as
-- { id, label, tabs }, then a terminal { session_id, block_id } if any session
-- has one. Returns nil and a message when the server can't be asked.
local function sessions(api)
  local r, err = api.call("session.list")
  if r == nil then return nil, err end
  local out, term = {}, nil
  for _, s in ipairs(r.sessions or {}) do
    -- session.list gives no tab counts. A session the caller isn't attached to
    -- can't be viewed, and just shows none; the app attaches to all of them.
    local view = api.session.view{ session_id = s.session_id }
    out[#out + 1] = { id = s.session_id, label = s.label or "", tabs = view and #view.windows }
    if term == nil and view then
      local block = terminal_block(view)
      if block then term = { session_id = s.session_id, block_id = block } end
    end
  end
  return out, term
end

-- Append parent's visible folders to dirs, sorted ignoring case.
local function add_dirs(dirs, parent, names)
  local visible = {}
  for _, name in ipairs(names) do
    if name:sub(1, 1) ~= "." then visible[#visible + 1] = name end
  end
  table.sort(visible, function(a, b)
    local ua, ub = a:upper(), b:upper()
    if ua ~= ub then return ua < ub end
    return a < b
  end)
  for _, name in ipairs(visible) do dirs[#dirs + 1] = parent .. "/" .. name end
end

-- Project directories on this machine, the roots in order.
local function local_dirs()
  -- -H: a root may be a symlink (~/Dropbox on macOS).
  local argv = { "find", "-H" }
  for _, root in ipairs(roots) do argv[#argv + 1] = home .. "/" .. root end
  for _, a in ipairs{ "-mindepth", "1", "-maxdepth", "1", "-type", "d" } do
    argv[#argv + 1] = a
  end
  -- A missing root makes find exit non-zero and still list the others.
  local r, err = rex.exec(argv, { stderr = false, timeout = 10 })
  if r == nil then error("sessionizer: " .. err, 0) end
  local by_parent = {}
  for dir in r.stdout:gmatch("[^\n]+") do
    local parent, name = dir:match("^(.*)/([^/]+)$")
    by_parent[parent] = by_parent[parent] or {}
    table.insert(by_parent[parent], name)
  end
  local dirs = {}
  for _, root in ipairs(roots) do
    add_dirs(dirs, home .. "/" .. root, by_parent[home .. "/" .. root] or {})
  end
  return dirs
end

-- Project directories on the host behind api, and its home directory, read
-- through the list_dir method of terminal term there.
local function remote_dirs(api, term)
  local dirs, remote_home = {}, ""
  for _, root in ipairs(roots) do
    local r = api.block.call(terminal, "list_dir", {
      session_id = term.session_id, block_id = term.block_id, path = "~/" .. root,
    })
    if r and r.status == "ok" then
      remote_home = r.home
      local names = {}
      for _, e in ipairs(r.entries or {}) do names[#names + 1] = e.name end
      add_dirs(dirs, r.path, names)
    end
  end
  return dirs, remote_home
end

-- Rows for host (a rex.server label, "" for this machine) from its sessions
-- and project directories. A project whose session is open is shown only as
-- that session.
--
-- Each project gets a session label unique on its host: the folder name with
-- . as _ (as tmux needed, so older sessions still match); when two folders
-- share that name, "<parent>/<name>" (develop/foo, work/foo); if that clashes
-- too, the ~ path. A session named plain "foo" then claims neither folder.
local function host_rows(host, host_home, sess, dirs, current)
  local projects, seen, count = {}, {}, {}
  for _, dir in ipairs(dirs) do
    if not seen[dir] then
      seen[dir] = true
      local parent, name = dir:match("^(.*)/([^/]+)$")
      local key = name:gsub("%.", "_")
      local key2 = parent:match("[^/]*$"):gsub("%.", "_") .. "/" .. key
      if host_home ~= "" and (parent .. "/"):sub(1, #host_home + 1) == host_home .. "/" then
        parent = "~" .. parent:sub(#host_home + 1)
      end
      projects[#projects + 1] = { dir = dir, name = name, parent = parent, key = key, key2 = key2 }
      count[key] = (count[key] or 0) + 1
    end
  end
  local count2 = {}
  for _, p in ipairs(projects) do
    p.label = p.key
    if count[p.key] > 1 then
      p.label = p.key2
      count2[p.label] = (count2[p.label] or 0) + 1
    end
  end
  local by_label = {}
  for _, p in ipairs(projects) do
    if count[p.key] > 1 and count2[p.key2] > 1 then p.label = p.parent .. "/" .. p.name end
    by_label[p.label] = by_label[p.label] or p
  end

  local rows, open = {}, {}
  for _, s in ipairs(sess) do
    open[s.label] = true
    local p = by_label[s.label]
    local subtitle = s.tabs and (s.tabs .. (s.tabs == 1 and " tab" or " tabs"))
    if s.id == current then subtitle = (subtitle and subtitle .. ", " or "") .. "current" end
    rows[#rows + 1] = {
      host = host, kind = s.id == current and "current" or "session", session_id = s.id,
      title = p and p.name or (s.label ~= "" and s.label or "unnamed session"),
      subtitle = subtitle,
    }
  end
  for _, p in ipairs(projects) do
    if not open[p.label] then
      rows[#rows + 1] = {
        host = host, kind = "project", label = p.label, dir = p.dir,
        title = p.name, subtitle = p.parent,
      }
    end
  end
  return rows
end

-- The rows of another host, or a note row saying why there are none.
local function remote_rows(host)
  local api, name = rex.server(host), host_name(host)
  -- A connection can only look inside sessions it is attached to.
  local sess, term
  if api.call("session.attach_all", { event_scope = "session" }) then
    sess, term = sessions(api)
  end
  if sess == nil then
    return { { host = host, kind = "note", title = "cannot reach " .. name } }
  end
  if term == nil then
    local rows = host_rows(host, "", sess, {})
    rows[#rows + 1] = {
      host = host, kind = "note",
      title = "no terminal on " .. name .. ": open one there to list its projects",
    }
    return rows
  end
  local dirs, remote_home = remote_dirs(api, term)
  return host_rows(host, remote_home, sess, dirs)
end

-- Rebuild the cache of the other hosts' rows.
local function refresh()
  local rows = {}
  for _, host in ipairs(rex.servers()) do
    for _, row in ipairs(remote_rows(host)) do rows[#rows + 1] = row end
  end
  -- A rename keeps a reader from seeing half a file.
  local tmp = cache_file .. ".tmp"
  local f = io.open(tmp, "w")
  if f == nil then
    rex.exec{ "mkdir", "-p", cache }
    f = assert(io.open(tmp, "w"))
  end
  f:write(rex.json.encode(rows))
  f:close()
  assert(os.rename(tmp, cache_file))
end

local function cached_rows()
  local f = io.open(cache_file)
  if f == nil then return {} end
  local rows = rex.json.decode(f:read("*a"))
  f:close()
  return type(rows) == "table" and rows or {}
end

-- The picker's items and a table from item id to row. This machine's rows are
-- fetched now and the other hosts' come from the cache. Open sessions go
-- first, the current one last among them so the one used before sits on top,
-- then projects, then notes about hosts. The host name is shown only when
-- there is more than one host.
local function list(current)
  local sess, err = sessions(rex)
  if sess == nil then error("sessionizer: " .. tostring(err), 0) end
  local rows = host_rows("", home, sess, local_dirs(), current)

  local names, hosts = nil, (rex.call("hosts.list") or {}).hosts or {}
  if #hosts > 0 then
    names = { [""] = local_name() }
    for _, h in ipairs(hosts) do names[h.label] = host_name(h.label) end
    for _, row in ipairs(cached_rows()) do
      -- Skip rows of a host removed since the refresh.
      if row.host ~= "" and names[row.host] then rows[#rows + 1] = row end
    end
  end

  local icons = { session = "code", current = "code", project = "folder", note = "server" }
  local items, by_id = {}, {}
  for _, kind in ipairs{ "session", "current", "project", "note" } do
    for _, row in ipairs(rows) do
      if row.kind == kind then
        local id = row.host .. "|" .. (row.session_id or row.dir or "")
        by_id[id] = row
        items[#items + 1] = {
          id = id, icon = icons[kind], title = row.title,
          subtitle = row.subtitle, detail = names and names[row.host],
        }
      end
    end
  end
  return items, by_id, #hosts > 0
end

-- The session a project row stands for on the server behind api, created if
-- no session has its label.
local function project_session(api, row)
  local where = row.host == "" and "this machine" or row.host
  -- Reuse a session with the same label, in case one opened since the list.
  -- Rex does not enforce unique labels.
  local r, err = api.call("session.list")
  if r == nil then
    error("sessionizer: could not list sessions on " .. where .. ": " .. tostring(err), 0)
  end
  for _, s in ipairs(r.sessions or {}) do
    if s.label == row.label then return s.session_id end
  end
  r, err = api.call("session.create", {
    label = row.label,
    initial_windows = { {
      layout = rex.layout.block{ flavor = terminal .. ".shell", options = { cwd = row.dir } },
    } },
  })
  if r == nil then
    error("sessionizer: could not create session " .. row.label .. " in " .. row.dir
      .. " on " .. where .. ": " .. tostring(err), 0)
  end
  return r.session_id
end

-- Script: switch the app labeled app to a row of another host, making a
-- session for a project if needed. The request has to go through the server
-- that owns the session, which knows the app by its label and not by the
-- client ID it has here. Without a matching label, the app is taken to be the
-- only one connected there.
local function open_remote(row, app)
  local api = rex.server(row.host)
  local id = row.session_id or project_session(api, row)
  local match, apps = nil, {}
  for _, c in ipairs((api.call("client.list") or {}).clients or {}) do
    if c.info and c.info.kind == "app" then
      apps[#apps + 1] = c.client_id
      if app ~= nil and c.info.label == app then match = match or c.client_id end
    end
  end
  local client = match or (#apps == 1 and apps[1])
  if not client then error("sessionizer: no app to switch is connected to " .. row.host, 0) end
  local r, err = api.call("client.perform", {
    client_id = client, action = "session.select", args = { session_id = id },
  })
  if r == nil then
    error("sessionizer: could not switch to " .. id .. " on " .. row.host .. ": " .. tostring(err), 0)
  end
end

-- Action: switch the app that ran it to a row, making a session for a project
-- if needed.
local function open(row, ctx)
  if row.kind == "note" then return end
  if row.host == "" then
    local id = row.session_id or project_session(rex, row)
    rex.client.queue("session.select", { session_id = id })
    return
  end
  local app
  for _, c in ipairs((rex.call("client.list") or {}).clients or {}) do
    if c.client_id == ctx.client_id then app = c.info and c.info.label end
  end
  local args = rex.json.encode{ open = row, app = app }
  local r, err = rex.exec({ cli, "do", script, "--args", args }, { timeout = 20 })
  if r == nil then error("sessionizer: " .. err, 0) end
  if not r.ok then
    error(r.stderr ~= "" and r.stderr or "sessionizer: could not open the row on " .. row.host, 0)
  end
end

rex.action{
  name     = "sessionizer",
  title    = "Open Project Session...",
  keywords = "project session sessionizer switch",
  args     = { key = "string?", list = "boolean?" },
  run      = function(ctx, args)
    local items, rows, remote = list(ctx.session_id)
    if remote then
      -- Detached, or Rex would stop it when the action returns. Short timeout:
      -- a stuck host must not keep the refresh around.
      rex.exec.start({ cli, "--timeout", "2s", "do", script, "refresh=true" },
        { detach = true, stdout = false, stderr = false })
    end
    if args.list then return items end

    local key, why = args.key, nil
    if key == nil then
      key, why = rex.ui.pick{
        title       = "Open session",
        placeholder = "Filter sessions and projects",
        items       = items,
      }
      if key == nil then
        if why ~= "cancelled" then rex.log("warn", "sessionizer: " .. why) end
        return
      end
    end
    if rows[key] == nil then error("sessionizer: no row " .. key, 0) end
    open(rows[key], ctx)
  end,
}

-- Run as a script by the action; rex.args is nil in init.lua.
if rex.args and rex.args.refresh then refresh() end
if rex.args and rex.args.open then open_remote(rex.args.open, rex.args.app) end
