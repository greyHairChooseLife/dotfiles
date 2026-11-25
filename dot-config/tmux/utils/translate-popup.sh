#!/usr/bin/env bash
# translate-popup.sh - translate the tmux copy-mode selection in a popup under it.
#
# Bind in tmux (selection arrives on stdin, copy-mode coords as args):
#   bind -T copy-mode-vi C-t send-keys -X copy-pipe-and-cancel "bash \
#     $TMUX_CONFIG_DIR/utils/translate-popup.sh #{selection_start_x} \
#     #{copy_cursor_x} #{copy_cursor_y} #{pane_id}"
#
# Korean selection -> English, anything else -> Korean.
# Backend: the free Google Apps Script relay used by translate.nvim (no API key).
set -uo pipefail

ENDPOINT="https://script.google.com/macros/s/AKfycbxLRZgWI3UyHvHuYVyH1StiXbzJDHyibO5XpVZm5kMlXFlzaFVtLReR0ZteEkUbecRpPQ/exec"
SELF="$(readlink -f "$0")"

# --show: paint the popup body, then wait so the popup does not vanish.
if [[ ${1:-} == --show ]]; then
    # Command substitution drops the trailing newline: printing it on the last
    # popup row would scroll the body up by one line. `budget` caps the rows so
    # a long body shows its beginning instead of scrolling to its tail.
    budget=${3:-0}
    total=$(wc -l <"$2")
    if ((budget > 0 && total > budget)); then
        body=$(head -n "$budget" "$2")
        body="$body …"
    else
        body=$(cat "$2")
    fi
    printf '%s' "$body"
    rm -f "$2"
    read -rsn1 >/dev/null 2>&1 || true
    exit 0
fi

# Left edge of the selection, then the copy-mode cursor (its tail), then the pane.
sx=${1:-}
cx=${2:-0}
cy=${3:-0}
pid=${4:-}
[[ $sx =~ ^[0-9]+$ ]] || sx=$cx

sel=$(cat)
[[ -z ${sel//[[:space:]]/} ]] && exit 0

# Pane and client geometry. The pane id must come from the binding: $TMUX_PANE
# can be stale, and a failed lookup silently yields zeros.
read -r pl pt cw ch <<<"$(tmux display-message -p -t "$pid" \
    '#{pane_left} #{pane_top} #{client_width} #{client_height}' 2>/dev/null)"
: "${pl:=0}" "${pt:=0}" "${cw:=80}" "${ch:=24}"
cap=$((cw - 6))
((cap > 100)) && cap=100

# Translate, wrap to `cap` terminal cells, and report the widest line.
tmp=$(mktemp "${TMPDIR:-/tmp}/tmux-translate.XXXXXX")
width=$(SEL="$sel" BODYFILE="$tmp" CAP="$cap" ENDPOINT="$ENDPOINT" python3 - <<'PY'
import json, os, re, sys, unicodedata, urllib.request

text = os.environ["SEL"].strip()
cap = int(os.environ["CAP"])

def cells(s):
    return sum(2 if unicodedata.east_asian_width(c) in "WF" else 1 for c in s)

target = "en" if re.search(r"[\uac00-\ud7a3\u3131-\u3163]", text) else "ko"
payload = json.dumps({"text": [text], "target": target, "source": ""}).encode()
request = urllib.request.Request(
    os.environ["ENDPOINT"], data=payload, headers={"Content-Type": "application/json"}
)
try:
    with urllib.request.urlopen(request, timeout=15) as response:
        translated = "\n".join(json.loads(response.read()))
except Exception as exc:  # network, HTTP or JSON failure
    print(exc, file=sys.stderr)
    sys.exit(1)

lines = []
for paragraph in translated.split("\n"):
    current = ""
    for word in paragraph.split(" "):
        candidate = word if not current else current + " " + word
        if cells(candidate) <= cap:
            current = candidate
            continue
        if current:
            lines.append(current)
        while cells(word) > cap:  # hard-break words longer than the cap
            cut = ""
            for char in word:
                if cells(cut + char) > cap:
                    break
                cut += char
            lines.append(cut)
            word = word[len(cut):]
        current = word
    lines.append(current)

with open(os.environ["BODYFILE"], "w") as out:
    out.write("\n".join(lines) + "\n")
print(max((cells(line) for line in lines), default=0))
PY
) || width=""

if [[ -z $width ]]; then
    rm -f "$tmp"
    tmux display-message -d 3000 "translate: request failed"
    exit 1
fi

w=$((width + 2))
((w < 32)) && w=32
((w > cap + 2)) && w=$((cap + 2))

lines=$(wc -l <"$tmp")
h=$((lines + 2)) # body + two border rows

# pane_top counts the pane's border row when pane-border-status is on, so the
# first text row of the pane is one lower there.
boff=0
[[ $(tmux show-options -gv pane-border-status 2>/dev/null) == top ]] && boff=1

# tmux takes a popup's -x as its left column and -y as its BOTTOM row. The box
# goes directly under the selected line, left-aligned with the selection start.
x=$((pl + (sx < cx ? sx : cx)))
top=$((pt + boff + cy + 1))
room=$((ch - top)) # rows left below the line, last one included

border=(-E -k)
rows=$((h - 2)) # text rows inside the frame
if ((room >= 3)); then
    ((h > room)) && h=$room
else
    # Only 1-2 rows left: drop the frame and show text rows alone.
    border=(-E -k -B)
    rows=$h
    if ((room < 1)); then # selected line is the last row: nothing below it
        room=1
        top=$((ch - 1))
    fi
    h=$room
fi
rows=$((rows < h ? rows : h))

((x + w > cw)) && x=$((cw - w))
((x < 0)) && x=0

cmd="bash $(printf '%q' "$SELF") --show $(printf '%q' "$tmp") $rows"
tmux display-popup -t "$pid" "${border[@]}" -w "$w" -h "$h" -x "$x" -y $((top + h)) "$cmd"
