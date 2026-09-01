#!/usr/bin/env python3
"""Generate svg/signal.svg — a static ASCII EKG trace, biomedical signal on a
monitor being the one motif that reads as both "health" and "tech" at once.

Unlike generate_stats.py, this isn't wired to live data or the daily
Action: it's decorative, so it's a one-off, run by hand when the shape
needs tweaking.

    python3 scripts/make_signal.py

The trace is plotted on a small character grid (rows = amplitude, columns =
time) and rasterized with a line-drawing walk, not by picking one symbol
per column independently — that produced disconnected floating marks with
no stroke joining them. Walking the longer of the two axes per segment
(steep segments need several rows filled per column) is what keeps the
line looking continuous in monospace.
"""
import os

WIDTH = 620
HEIGHT = 90
PAD = 24
ROWS = 5
BG = "#0d1117"
BORDER = "#30363d"
ACCENT = "#58a6ff"
MUTED = "#8b949e"
FONT = (
    'ui-monospace, "Cascadia Code", "SFMono-Regular", Consolas, '
    '"Liberation Mono", Menlo, monospace'
)

# One cardiac cycle as (x, y) vertices, y in 0 (baseline) .. ROWS-1 (peak).
# P bump, sharp QRS spike, T bump, then a flat run out to the next beat.
UNIT_W = 32
CYCLE = [
    (0, 0), (5, 0),             # baseline
    (7, 2), (9, 0),             # P wave
    (13, 0),
    (15, 4), (17, 0),           # QRS spike — wide enough apart that the
    (21, 0),                    # up-stroke and down-stroke land in
    (23, 2), (25, 0),           # different columns instead of overwriting
    (UNIT_W, 0),                # baseline out to the next beat
]


def draw_line(grid, x0, y0, x1, y1):
    dx, dy = x1 - x0, y1 - y0
    steps = max(abs(dx), abs(dy), 1)
    char = "_" if dy == 0 else ("/" if dy > 0 else "\\") if dx != 0 else "|"
    for i in range(steps + 1):
        x = round(x0 + dx * i / steps)
        y = round(y0 + dy * i / steps)
        if 0 <= y < len(grid) and 0 <= x < len(grid[0]):
            grid[y][x] = char


def build_grid(cols):
    grid = [[" "] * cols for _ in range(ROWS)]
    beats = cols // UNIT_W + 1
    for b in range(beats):
        offset = b * UNIT_W
        for (x0, y0), (x1, y1) in zip(CYCLE, CYCLE[1:]):
            draw_line(grid, offset + x0, y0, offset + x1, y1)
    return grid


def build(cols=104):
    grid = build_grid(cols)
    rows_top_to_bottom = list(reversed(grid))  # highest amplitude drawn first

    x, y0 = PAD, PAD
    line_h = 13
    parts = [
        f'<svg width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}" '
        f'xmlns="http://www.w3.org/2000/svg">',
        f"<style>text {{ font-family: {FONT}; }}</style>",
        f'<rect x="0.5" y="0.5" width="{WIDTH - 1}" height="{HEIGHT - 1}" rx="10" '
        f'fill="{BG}" stroke="{BORDER}"/>',
        f'<text x="{x}" y="{y0}" fill="{MUTED}" font-size="10" '
        f'letter-spacing="2">SIGNAL</text>',
    ]
    top = y0 + 18
    for i, row in enumerate(rows_top_to_bottom):
        text = "".join(row)
        parts.append(
            f'<text x="{x}" y="{top + i * line_h}" fill="{ACCENT}" font-size="13" '
            f'xml:space="preserve" style="letter-spacing:1px">{text}</text>'
        )
    parts.append("</svg>\n")
    return "\n".join(parts)


def main():
    out_dir = os.environ.get("OUT_DIR", "svg")
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, "signal.svg")
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(build())
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
