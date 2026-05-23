#!/usr/bin/env python3
"""ks - kitty session helper.

Usage:
  ks <path>     Open a new kitty OS window tagged with session_name=<folder>-<uid>.
  ks -l         List all active kitty sessions.
  ks -s <name>  Switch focus to the session with the given name.
  ks -k         Interactive picker (fzf, multi-select) over active sessions; kill on Enter.
  ks -k <name>  Kill the session with the given name (closes its OS window).
  ks -k --all   Kill all sessions except the currently focused one.
  ks -i         Interactive picker (fzf) over active sessions; switch on select.
  ks -n         Interactive picker (fzf) over KS_LOCATIONS subdirs; create on select.

Env vars:
  KS_LOCATIONS      Colon-separated parent dirs for `-n` candidate enumeration.
  KS_TEMPLATE       Path to session-file template (default: ~/.config/kitty/sessions/template.kitty-session).
  KS_SESSIONS_DIR   Directory of *.kitty-session files for `-n` (default: ~/.config/kitty/sessions).
"""

from __future__ import annotations

import glob
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from dataclasses import dataclass


HOME = os.environ.get("HOME", "")


def resolve_socket() -> str:
    listen = os.environ.get("KITTY_LISTEN_ON")
    if listen:
        return listen
    candidates = sorted(
        glob.glob("/tmp/mykitty-*"),
        key=lambda p: os.path.getmtime(p),
        reverse=True,
    )
    if not candidates:
        sys.stderr.write("ks: no kitty socket found (is kitty running with listen_on?)\n")
        sys.exit(1)
    return "unix:" + candidates[0]


SOCKET = resolve_socket()


# --- low-level helpers ---


def strip_private(p: str) -> str:
    return p[len("/private"):] if p.startswith("/private/") else p


def kitty_at(*args: str, check: bool = True) -> str:
    cmd = ["kitty", "@", "--to", SOCKET, *args]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        if check:
            sys.stderr.write("ks: " + " ".join(shlex.quote(a) for a in cmd) + "\n")
            sys.stderr.write("ks: " + res.stderr.strip() + "\n")
            sys.exit(1)
        return ""
    return res.stdout.strip()


def kitty_ls() -> list:
    raw = kitty_at("ls")
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, ValueError):
        return []


# --- domain ---


@dataclass
class SessionRow:
    name: str
    cwd: str
    launch_path: str
    focused: bool
    last_focused_at: float


def find_current_session_name(data: list) -> str | None:
    """The session containing the most-recently-focused session-window in the
    focused tab — i.e. the session the user came from when an overlay grabbed
    focus. Returns None if the focused tab has no session-tagged window.
    """
    for os_win in data:
        if not os_win.get("is_focused"):
            continue
        for tab in os_win.get("tabs", []):
            if not tab.get("is_focused"):
                continue
            best_name: str | None = None
            best_t = -1.0
            for w in tab.get("windows", []):
                name = (w.get("user_vars") or {}).get("session_name")
                if not name:
                    continue
                t = float(w.get("last_focused_at") or 0)
                if t > best_t:
                    best_name, best_t = name, t
            return best_name
    return None


def list_sessions(data: list | None = None) -> list[SessionRow]:
    if data is None:
        data = kitty_ls()
    rows: list[SessionRow] = []
    for os_win in data:
        os_focused = os_win.get("is_focused", False)
        for tab in os_win.get("tabs", []):
            tab_focused = tab.get("is_focused", False)
            for w in tab.get("windows", []):
                uv = w.get("user_vars") or {}
                name = uv.get("session_name", "")
                if not name:
                    continue
                fg = w.get("foreground_processes") or []
                cwd = (fg[0].get("cwd") if fg else None) or w.get("cwd", "")
                cwd = strip_private(cwd)
                launch_path = strip_private(uv.get("session_path") or cwd)
                rows.append(SessionRow(
                    name=name,
                    cwd=cwd,
                    launch_path=launch_path,
                    focused=bool(os_focused and tab_focused and w.get("is_focused", False)),
                    last_focused_at=float(w.get("last_focused_at") or 0),
                ))

    by_name: dict[str, SessionRow] = {}
    for r in rows:
        cur = by_name.get(r.name)
        if cur is None:
            by_name[r.name] = r
            continue
        if r.focused and not cur.focused:
            by_name[r.name] = r
        elif r.focused == cur.focused and r.last_focused_at > cur.last_focused_at:
            by_name[r.name] = r

    items = sorted(
        by_name.values(),
        key=lambda r: (-int(r.focused), -r.last_focused_at, r.name),
    )
    return items


def extract_session_name_from_file(path: str) -> str | None:
    try:
        with open(path) as f:
            for raw in f:
                line = raw.strip()
                if not line or line.startswith("#"):
                    continue
                if line.split()[0] == "launch":
                    m = re.search(r"--var=session_name=(\S+)", line)
                    return m.group(1) if m else None
                # Match bash semantics: only check the first non-comment directive
                # if it is `launch`. Anything else means "no baked tag here."
                return None
    except OSError:
        return None
    return None


def session_is_running(name: str) -> bool:
    data = kitty_ls()
    for os_win in data:
        for tab in os_win.get("tabs", []):
            for w in tab.get("windows", []):
                if (w.get("user_vars") or {}).get("session_name") == name:
                    return True
    return False


def apply_session_file(path: str, session_name: str, initial_cwd: str) -> int:
    """Render and replay a (possibly templated) kitty session file as `kitty @`
    calls against the running kitty over SOCKET. Returns 0 on success, 1 on error.
    """
    try:
        with open(path) as f:
            text = f.read()
    except OSError as e:
        sys.stderr.write(f"ks: cannot read session file: {path}: {e}\n")
        return 1

    text = text.replace("${KS_CWD}", initial_cwd).replace("${KS_SESSION_NAME}", session_name)

    cwd = initial_cwd
    os_window_title = session_name or os.path.basename(path)
    first_launch_done = False
    last_window_id: str | None = None
    focused_window_id: str | None = None
    tag_match: str | None = None

    def extract_tag(launch_args: list[str]) -> str | None:
        for a in launch_args:
            m = re.match(r"--var=session_name=(.+)$", a)
            if m:
                return m.group(1)
        return None

    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = shlex.split(line)
        directive, rest = parts[0], parts[1:]

        if directive == "cd":
            target = rest[0] if rest else cwd
            target = os.path.expanduser(target)
            cwd = target if os.path.isabs(target) else os.path.abspath(os.path.join(cwd, target))
        elif directive == "os_window_title":
            os_window_title = " ".join(rest)
        elif directive == "launch":
            if not first_launch_done:
                args = [
                    "launch",
                    "--type=os-window",
                    "--cwd=" + cwd,
                    "--os-window-title=" + os_window_title,
                    *rest,
                ]
                tag_match = "var:session_name=" + (session_name or extract_tag(rest) or "")
            else:
                match = ("id:" + last_window_id) if last_window_id else (tag_match or "")
                args = ["launch", "--match", match, "--cwd=" + cwd, *rest]
            wid = kitty_at(*args)
            if wid.isdigit():
                last_window_id = wid
            first_launch_done = True
        elif directive == "new_tab":
            match = ("id:" + last_window_id) if last_window_id else (tag_match or "")
            args = ["launch", "--type=tab", "--match", match, "--cwd=" + cwd]
            if rest:
                args.append("--tab-title=" + " ".join(rest))
            wid = kitty_at(*args)
            if wid.isdigit():
                last_window_id = wid
        elif directive == "focus":
            focused_window_id = last_window_id
        elif directive == "focus_os_window":
            pass
        else:
            sys.stderr.write(f"ks: warning: unsupported session-file directive: {directive}\n")

    if not first_launch_done:
        sys.stderr.write("ks: session file defined no launch directives\n")
        return 1

    if focused_window_id:
        kitty_at("focus-window", "--match", "id:" + focused_window_id)
    return 0


def create_session(abs_path: str) -> str:
    folder_name = os.path.basename(abs_path)
    uid = os.urandom(3).hex()
    session_name = f"{folder_name}-{uid}"
    template = os.environ.get("KS_TEMPLATE") or os.path.join(
        HOME, ".config/kitty/sessions/template.kitty-session"
    )
    if not os.access(template, os.R_OK):
        sys.stderr.write(f"ks: template not found or unreadable: {template}\n")
        sys.stderr.write("ks: set KS_TEMPLATE to override, or create the default template\n")
        pause_overlay()
        sys.exit(1)
    if apply_session_file(template, session_name, abs_path) != 0:
        pause_overlay()
        sys.exit(1)
    return session_name


def launch_session_file(path: str) -> None:
    name = extract_session_name_from_file(path)
    if name and session_is_running(name):
        cmd_switch(name)
        return
    if apply_session_file(path, name or "", HOME) != 0:
        pause_overlay()
        sys.exit(1)
    if name:
        print(name)


def kill_session_by_name(name: str) -> bool:
    data = kitty_ls()
    for os_win in data:
        win_ids: list[str] = []
        found = False
        for tab in os_win.get("tabs", []):
            for w in tab.get("windows", []):
                wid = w.get("id")
                if wid is not None:
                    win_ids.append(str(wid))
                if (w.get("user_vars") or {}).get("session_name") == name:
                    found = True
        if found:
            for wid in win_ids:
                kitty_at("close-window", "--match", "id:" + wid, check=False)
            return True
    return False


# --- display + fzf ---


def display_cwd(p: str) -> str:
    if HOME and p.startswith(HOME):
        return "~" + p[len(HOME):]
    return p


def format_session_table(rows: list[SessionRow]) -> list[tuple[str, str]]:
    """Returns [(name, fzf-display-line), ...] shared by cmd_list/-i/-k."""
    if not rows:
        return []
    name_w = max(len(r.name) for r in rows)
    out: list[tuple[str, str]] = []
    for r in rows:
        out.append((r.name, f"{r.name:<{name_w}}  {display_cwd(r.cwd)}"))
    return out


def pause_overlay() -> None:
    if not sys.stderr.isatty():
        return
    try:
        sys.stderr.write("ks: press any key to close...")
        sys.stderr.flush()
        with open("/dev/tty", "rb", buffering=0) as tty:
            tty.read(1)
        sys.stderr.write("\n")
    except OSError:
        pass


def require_fzf() -> None:
    if shutil.which("fzf") is None:
        sys.stderr.write("ks: fzf not found in PATH (brew install fzf)\n")
        pause_overlay()
        sys.exit(1)


def run_fzf(
    lines: list[str],
    *,
    prompt: str,
    header: str,
    multi: bool,
    with_nth: int,
    delimiter: str = "\t",
) -> list[str] | None:
    """Run fzf over `lines`. Returns selected lines, or None on cancel."""
    cmd = [
        "fzf",
        "--ansi",
        "--reverse",
        "--height=40%",
        f"--with-nth={with_nth}",
        f"--delimiter={delimiter}",
        f"--prompt={prompt}",
        f"--header={header}",
    ]
    cmd.append("--multi" if multi else "--no-multi")
    res = subprocess.run(
        cmd,
        input="\n".join(lines),
        capture_output=True,
        text=True,
    )
    # fzf exit: 0 = match, 1 = no match, 2 = error, 130 = ctrl-c/esc
    if res.returncode != 0:
        return None
    out = res.stdout.strip("\n")
    if not out:
        return None
    return out.split("\n")


# --- commands ---


def cmd_list() -> None:
    rows = list_sessions()
    if not rows:
        return
    name_w = max(len(r.name) for r in rows)
    for r in rows:
        marker = "*" if r.focused else " "
        print(f"{marker} {r.name:<{name_w}}  {display_cwd(r.cwd)}")


def cmd_switch(name: str) -> None:
    cmd = ["kitty", "@", "--to", SOCKET, "focus-window", "--match", f"var:session_name={name}"]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0:
        return
    err = res.stderr.strip()
    if "No matching windows" in err:
        sys.stderr.write(f"ks: no session named '{name}'\n")
    else:
        sys.stderr.write(f"ks: {err or f'failed to focus session ' + repr(name)}\n")
    sys.exit(1)


def cmd_kill(name: str) -> None:
    if not kill_session_by_name(name):
        sys.stderr.write(f"ks: no session named '{name}'\n")
        sys.exit(1)


def cmd_kill_all() -> None:
    data = kitty_ls()
    focused_os = None
    for os_win in data:
        if os_win.get("is_focused"):
            focused_os = os_win.get("id")
            break
    if focused_os is None:
        sys.stderr.write("ks: could not identify the focused kitty OS window\n")
        sys.exit(2)

    ids: list[str] = []
    for os_win in data:
        if os_win.get("id") == focused_os:
            continue
        has_session = any(
            (w.get("user_vars") or {}).get("session_name")
            for tab in os_win.get("tabs", [])
            for w in tab.get("windows", [])
        )
        if not has_session:
            continue
        for tab in os_win.get("tabs", []):
            for w in tab.get("windows", []):
                wid = w.get("id")
                if wid is not None:
                    ids.append(str(wid))

    if not ids:
        sys.stderr.write("ks: no other sessions to kill\n")
        return

    count = 0
    for wid in ids:
        kitty_at("close-window", "--match", "id:" + wid, check=False)
        count += 1
    sys.stderr.write(f"ks: closed {count} session window(s)\n")


def cmd_pick_session() -> None:
    require_fzf()
    data = kitty_ls()
    rows = list_sessions(data)
    if not rows:
        sys.stderr.write("ks: no active sessions\n")
        pause_overlay()
        return
    # The overlay grabs focus, so kitty no longer reports any session window as
    # focused. To put the *previously* focused (= last visited) session at the
    # fzf cursor and the user's current session at the bottom, identify the
    # current session from the focused tab and rank it last.
    current_name = find_current_session_name(data)
    rows = sorted(
        rows,
        key=lambda r: (r.name == current_name, -r.last_focused_at),
    )
    table = format_session_table(rows)
    name_w = max(len(n) for n, _ in table)
    lines = [f"{name}\t{name:<{name_w}}  {display_cwd(r.cwd)}" for (name, _), r in zip(table, rows)]
    chosen = run_fzf(
        lines,
        prompt="session > ",
        header="Enter: switch • Esc: cancel",
        multi=False,
        with_nth=2,
    )
    if not chosen:
        return
    name = chosen[0].split("\t", 1)[0]
    cmd_switch(name)


def cmd_pick_kill() -> None:
    require_fzf()
    rows = list_sessions()
    if not rows:
        sys.stderr.write("ks: no active sessions\n")
        pause_overlay()
        return
    # Ascending: focused session lands at bottom of the fzf list — safer default
    # when the action is destructive.
    rows = sorted(rows, key=lambda r: (r.focused, r.last_focused_at))
    table = format_session_table(rows)
    name_w = max(len(n) for n, _ in table)
    lines = [f"{name}\t{name:<{name_w}}  {display_cwd(r.cwd)}" for (name, _), r in zip(table, rows)]
    chosen = run_fzf(
        lines,
        prompt="kill > ",
        header="Tab: select • Enter: kill • Esc: cancel",
        multi=True,
        with_nth=2,
    )
    if not chosen:
        return
    killed = 0
    for line in chosen:
        name = line.split("\t", 1)[0]
        if kill_session_by_name(name):
            killed += 1
    sys.stderr.write(f"ks: killed {killed} session(s)\n")


def cmd_pick_new() -> None:
    require_fzf()
    locations = os.environ.get("KS_LOCATIONS", "")
    if not locations:
        sys.stderr.write(
            "ks: KS_LOCATIONS is not set.\n"
            'Example: export KS_LOCATIONS="$HOME/projects:$HOME/.config"\n'
        )
        pause_overlay()
        sys.exit(1)

    locs = [os.path.expanduser(p) for p in locations.split(":") if p]
    sessions_dir = os.environ.get("KS_SESSIONS_DIR") or os.path.join(HOME, ".config/kitty/sessions")

    data = kitty_ls()
    active_paths: set[str] = set()
    active_names: set[str] = set()
    for os_win in data:
        for tab in os_win.get("tabs", []):
            for w in tab.get("windows", []):
                uv = w.get("user_vars") or {}
                name = uv.get("session_name")
                if not name:
                    continue
                active_names.add(name)
                fg = w.get("foreground_processes") or []
                cwd = (fg[0].get("cwd") if fg else None) or w.get("cwd", "")
                active_paths.add(strip_private(uv.get("session_path") or cwd))

    # Directory candidates under KS_LOCATIONS (not already a running session).
    seen: set[str] = set()
    dirs: list[tuple[str, str]] = []  # (label, abs_path)
    for loc in locs:
        if not os.path.isdir(loc):
            continue
        try:
            names = sorted(os.listdir(loc))
        except OSError:
            continue
        for n in names:
            if n.startswith("."):
                continue
            full = os.path.join(loc, n)
            if not os.path.isdir(full):
                continue
            try:
                abs_full = strip_private(os.path.realpath(full))
            except OSError:
                abs_full = strip_private(full)
            if abs_full in active_paths or abs_full in seen:
                continue
            seen.add(abs_full)
            dirs.append((os.path.basename(abs_full), abs_full))
    dirs.sort(key=lambda x: (x[0].lower(), x[1]))

    # Session-file candidates (sessions_dir/*.kitty-session, excluding template).
    sessions: list[tuple[str, str, bool]] = []  # (label, full_path, running)
    if sessions_dir and os.path.isdir(sessions_dir):
        try:
            entries = sorted(os.listdir(sessions_dir))
        except OSError:
            entries = []
        for n in entries:
            if n.startswith(".") or not n.endswith(".kitty-session"):
                continue
            if n == "template.kitty-session":
                continue
            full = os.path.join(sessions_dir, n)
            baked = extract_session_name_from_file(full)
            label = n[: -len(".kitty-session")]
            running = bool(baked) and baked in active_names
            sessions.append((label, full, running))
    sessions.sort(key=lambda x: x[0].lower())

    if not dirs and not sessions:
        sys.stderr.write("ks: no available directories or session files\n")
        pause_overlay()
        return

    label_w = max(
        [len(s[0]) for s in sessions] + [len(d[0]) for d in dirs] + [0]
    )

    lines: list[str] = []
    for label, full, running in sessions:
        suffix = "  (running)" if running else ""
        lines.append(f"session\t{full}\t[session] {label:<{label_w}}{suffix}")
    for label, abs_full in dirs:
        lines.append(f"dir\t{abs_full}\t[dir]     {label:<{label_w}}  {display_cwd(abs_full)}")

    chosen = run_fzf(
        lines,
        prompt="new > ",
        header="Enter: open • Esc: cancel",
        multi=False,
        with_nth=3,
    )
    if not chosen:
        return
    parts = chosen[0].split("\t", 2)
    if len(parts) < 2:
        return
    kind, selector = parts[0], parts[1]
    if kind == "session":
        launch_session_file(selector)
    elif kind == "dir":
        name = create_session(selector)
        print(name)
    else:
        sys.stderr.write(f"ks: unknown selection type: {kind}\n")
        pause_overlay()
        sys.exit(1)


# --- dispatch ---


USAGE = """Usage:
  ks <path>     Open a new kitty OS window tagged with session_name=<folder>-<uid>.
  ks -l         List all active kitty sessions.
  ks -s <name>  Switch focus to the session with the given name.
  ks -k         Interactive picker (fzf, multi-select) over active sessions; kill on Enter.
  ks -k <name>  Kill the session with the given name (closes its OS window).
  ks -k --all   Kill all sessions except the currently focused one.
  ks -i         Interactive picker (fzf) over active sessions; switch on select.
  ks -n         Interactive picker (fzf) over KS_LOCATIONS subdirs; create on select.
"""


def main(argv: list[str]) -> int:
    if not argv:
        sys.stderr.write(USAGE)
        return 1

    head = argv[0]
    rest = argv[1:]

    if head in ("-h", "--help"):
        sys.stdout.write(USAGE)
        return 0
    if head in ("-l", "--list"):
        cmd_list()
        return 0
    if head in ("-s", "--switch"):
        if not rest or not rest[0]:
            sys.stderr.write("ks: -s requires a session name\n")
            return 1
        cmd_switch(rest[0])
        return 0
    if head in ("-k", "--kill"):
        if not rest or not rest[0]:
            cmd_pick_kill()
        elif rest[0] in ("--all", "-a"):
            cmd_kill_all()
        else:
            cmd_kill(rest[0])
        return 0
    if head in ("-i", "--interactive"):
        cmd_pick_session()
        return 0
    if head in ("-n", "--new"):
        cmd_pick_new()
        return 0

    target = head
    if not os.path.isdir(target):
        sys.stderr.write(f"ks: not a directory: {target}\n")
        return 1
    abs_path = os.path.abspath(target)
    name = create_session(abs_path)
    print(name)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(130)
