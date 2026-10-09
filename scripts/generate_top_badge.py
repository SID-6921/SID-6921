#!/usr/bin/env python3
"""Generate a small self-hosted "#1 in this list" seal badge as one SVG.

Same reasoning as generate_stats.py: no third-party badge service, one
opaque-background SVG so it renders the same on both of GitHub's themes.
Overwritten each run by update_oss_table.sh; which repo gets to display it
is decided by that script, this file only draws the seal itself.
"""
import os

OUT_DIR = os.environ.get("OUT_DIR", "svg")
SIZE = 72

SVG = f'''<svg width="{SIZE}" height="{SIZE}" viewBox="0 0 {SIZE} {SIZE}" xmlns="http://www.w3.org/2000/svg">
<defs>
  <radialGradient id="g" cx="35%" cy="30%" r="75%">
    <stop offset="0%" stop-color="#fff3c4"/>
    <stop offset="55%" stop-color="#f2c94c"/>
    <stop offset="100%" stop-color="#b8860b"/>
  </radialGradient>
</defs>
<circle cx="{SIZE/2}" cy="{SIZE/2}" r="{SIZE/2 - 3}" fill="url(#g)" stroke="#8a6d1a" stroke-width="2.5"/>
<circle cx="{SIZE/2}" cy="{SIZE/2}" r="{SIZE/2 - 9}" fill="none" stroke="#8a6d1a" stroke-width="1" stroke-dasharray="2.5 3"/>
<text x="{SIZE/2}" y="{SIZE/2 - 2}" text-anchor="middle" font-family="ui-monospace, Menlo, monospace" font-size="22" font-weight="800" fill="#3d2e05">#1</text>
<text x="{SIZE/2}" y="{SIZE/2 + 17}" text-anchor="middle" font-family="ui-monospace, Menlo, monospace" font-size="8" font-weight="700" letter-spacing="0.5" fill="#3d2e05">TOP REPO</text>
</svg>
'''

if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, "top-repo-badge.svg")
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(SVG)
    print(f"wrote {path}")
