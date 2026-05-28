from kitty.boss import get_boss


def _session_name_for_window(w):
    return (getattr(w, 'user_vars', None) or {}).get('session_name', '')


def draw_title(data):
    name = ''
    try:
        target_tab_id = data.get('tab_id')
        boss = get_boss()
        target_os_window = None
        for tab in boss.all_tabs:
            if tab.id == target_tab_id:
                target_os_window = tab.os_window_id
                w = getattr(tab, 'active_window', None) or next(iter(tab), None)
                if w is not None:
                    name = _session_name_for_window(w)
                break
        if not name and target_os_window is not None:
            for tab in boss.all_tabs:
                if tab.os_window_id != target_os_window:
                    continue
                for w in tab:
                    sn = _session_name_for_window(w)
                    if sn:
                        name = sn
                        break
                if name:
                    break
    except Exception:
        pass
    return f'{name}:' if name else ''
