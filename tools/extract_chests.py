"""Extract chest tables from a decompiled MapData.as into data/chests.json.

Usage: python tools/extract_chests.py [path/to/MapData.as]
Default input: build/export-v2/scripts/MapData.as (export from the real SWF first).
"""
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO / "build/export-v2/scripts/MapData.as"
OUT = REPO / "data/chests.json"

text = SRC.read_text(encoding="utf-8", errors="replace")

map_re = re.compile(r"if\(mapNo == (\d+)\)")
area_re = re.compile(r"setArea\((\w+)\)")
# "mc":"chest0", "type":CHEST, "data":[...]   (data list is on one line in FFDec output)
chest_re = re.compile(
    r'"mc":"chest(\d+)",\s*"type":CHEST,\s*"data":\[([^\]]*)\]', re.S)
token_re = re.compile(r"(Items|Equips|Spells)\.(\w+)|(-?\d+)")

chests = []
cur_map, cur_area = None, None
events = []  # (pos, kind, value)
for m in map_re.finditer(text):
    events.append((m.start(), "map", int(m.group(1))))
for m in area_re.finditer(text):
    events.append((m.start(), "area", m.group(1)))
for m in chest_re.finditer(text):
    events.append((m.start(), "chest", (int(m.group(1)), m.group(2))))
events.sort()

for pos, kind, val in events:
    if kind == "map":
        cur_map = val
    elif kind == "area":
        cur_area = val
    elif kind == "chest":
        idx, raw = val
        contents = []
        toks = [t for t in token_re.finditer(raw)]
        i = 0
        while i < len(toks):
            t = toks[i]
            if t.group(1):  # Items/Equips/Spells.name
                kindc = {"Items": "i", "Equips": "e", "Spells": "s"}[t.group(1)]
                name = t.group(2)
                qty = 1
                if i + 1 < len(toks) and toks[i + 1].group(3) is not None:
                    qty = int(toks[i + 1].group(3))
                    i += 1
                contents.append([kindc, name, qty])
            elif t.group(3) is not None:
                # bare number not following an object token: treat as money
                contents.append(["money", "", int(t.group(3))])
            i += 1
        chests.append({"map": cur_map, "chest": idx, "area": cur_area,
                       "contents": contents})

OUT.parent.mkdir(exist_ok=True)
OUT.write_text(json.dumps(chests, indent=1), encoding="utf-8")
areas = {}
for c in chests:
    areas.setdefault(c["area"], []).append(c)
print(f"{len(chests)} chests across {len(set(c['map'] for c in chests))} maps")
for a, cs in areas.items():
    print(f"  {a}: {len(cs)} chests, maps {sorted(set(c['map'] for c in cs))[:12]}")
