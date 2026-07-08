#!/bin/bash
# Notify when a display is connected, showing its connector name + resolution.
#
# sway has no per-output "on connect" hook, so we subscribe to its IPC `output`
# event stream and diff the active-output list on each event: any name that has
# appeared since the previous event is a freshly connected monitor. (The output
# event also fires on scale/mode/position changes -- the diff ignores those,
# since the set of names is unchanged.) Several monitors appearing at once are
# each handled by the inner loop, so a dock that lights up 2-3 screens notifies
# for each.
#
# The internal panel (eDP-1) is never announced -- lid-switch.sh disables and
# re-enables it, which would otherwise fire a bogus "connected" on every lid
# open. Only genuinely external displays notify.
#
# Everything is defensive: missing make/model/mode/refresh degrade to a shorter
# message rather than an error, and an empty lookup still notifies with the name.
#
# Started once from sway/config via `exec` (survives reloads, so no duplicates).

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_dir/sway-lib.sh" || { echo "sway-lib.sh not found" >&2; exit 1; }

# Snapshot what's already active at startup so we don't notify for it.
prev=$(active_names)

swaymsg -t subscribe -m '["output"]' 2>/dev/null | while read -r _; do
    outputs=$(sway_outputs)
    [ -z "$outputs" ] && continue
    cur=$(active_names "$outputs")

    for name in $cur; do
        case " $prev " in *" $name "*) continue ;; esac   # already known -> skip
        [ "$name" = "$INTERNAL" ] && continue             # internal panel: not a "connect"
                                                          # (lid-switch re-enables it on open)

        # Newly connected. Build a multi-line body, tolerant of missing fields:
        #   Make Model
        #   WxH@RRHz
        #   scale <current> (ideal ~<n>)
        # Any field being null/absent degrades that line instead of erroring:
        # vendor words that are empty/"Unknown" are dropped, a null mode becomes
        # "resolution unavailable", a null/0 refresh drops the @Hz suffix.
        #
        # "ideal" = the scale that gives this output the same logical desktop
        # size as the laptop (eDP-1), i.e. the same UI size you're used to:
        #   ideal = diagonal(native mode) / diagonal(laptop logical size)
        # rounded to the nearest 0.25 and floored at 1.0. The laptop logical
        # size is read live from eDP-1's rect (fallback 1920x1200 if absent).
        # It's a heuristic (true "ideal" needs physical size, which sway doesn't
        # expose) but matches the "laptop never changes" reasoning.
        info=$(printf '%s' "$outputs" | jq -r --arg n "$name" '
            . as $all
            | ([$all[] | select(.name == "eDP-1")][0]) as $lap
            | ($lap.rect.width  // 1920) as $lw
            | ($lap.rect.height // 1200) as $lh
            | ($all[] | select(.name == $n))
            | ([.make, .model]
               | map(select(. != null and . != "" and . != "Unknown"))
               | join(" ")) as $vendor
            | (.current_mode) as $m
            | (.scale) as $cs
            | (if $m == null or $m.width == null or $m.height == null then
                   "resolution unavailable"
               else
                   "\($m.width)x\($m.height)"
                   + (if (($m.refresh // 0) > 0) then "@\((($m.refresh) / 1000) | floor)Hz" else "" end)
               end) as $res
            # scale line: current (rounded, so nwg float-noise like 1.4999 shows
            # as 1.5) plus the computed ideal when a real mode is available.
            | (if $cs == null then null else (($cs * 100 | round) / 100) end) as $curScale
            | (if $m != null and $m.width != null and $m.height != null and ($lw * $lh) > 0 then
                   ( ( (($m.width * $m.width) + ($m.height * $m.height)) | sqrt )
                     / ( (($lw * $lw) + ($lh * $lh)) | sqrt ) ) as $ratio
                 | (($ratio / 0.25) | round) * 0.25
                 | (if . < 1 then 1 else . end)
               else null end) as $ideal
            | ([ (if $curScale != null then "scale \($curScale)" else empty end),
                 (if $ideal    != null then "ideal ~\($ideal)"   else empty end) ]
               | join(" · ")) as $scaleLine
            | ([ (if $vendor != "" then $vendor else empty end),
                 $res,
                 (if $scaleLine != "" then $scaleLine else empty end) ]
               | join("\n"))
        ' 2>/dev/null)

        [ -z "$info" ] && info="(details unavailable)"
        notify-send -i video-display "Display connected: $name" "$info"
    done

    prev="$cur"
done
