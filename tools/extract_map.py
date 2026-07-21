"""Extract EBF4's region graph from the decompiled MapData.as.

Per-map setup lives in `init()` as `if(mapNo == N) { setArea(AREA); ...
initScenes(..., Items.X, true); initKey(_, Items.Y); ... }` blocks. We pull, per
map:
  - its area (from setArea(<CONST>), falling back to chests.json)
  - the items that BLOCK traversal on it (initScenes 6th arg == true; initKey)
  - best-effort door adjacency (`.into = N`)

Output: apworld/ebf4/data/regions.json. The world's logic backbone is
`map_requires` accumulated along the canonical area order (see regions.py);
`edges` are a best-effort refinement.

    python tools/extract_map.py
"""
import json
import pathlib
import re

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "reference" / "ebf4-decompile" / "scripts" / "default_package" / "MapData.as"
CHESTS = json.loads((REPO / "apworld" / "ebf4" / "data" / "chests.json").read_text())

ITEM = r"Items\.([A-Za-z0-9_]+)"

# MapData area constants -> friendly names (mirrors data.AREA_NAMES; kept local so
# the extractor has no Archipelago import dependency).
AREA_NAMES = {
    "TOWN1": "Greenwood", "GRAVEYARD": "Graveyard", "ASHWOOD": "Ashwood Forest",
    "CAVERNS": "Crystal Caverns", "TOWN2": "Whitefall Town",
    "FACTORY": "The Kitten Kaboodle", "JUNGLE": "Lankyroot Jungle",
    "TOWN3": "Redpine Town", "TEMPLE": "Temple of Godcat", "EXTRA": "Battle Mountain",
}


def map_blocks(text):
    """Yield (mapNo, block_text) for each `if(mapNo == N)` block."""
    marks = [(int(m.group(1)), m.start())
             for m in re.finditer(r"if\(mapNo == (\d+)\)", text)]
    for i, (mid, start) in enumerate(marks):
        end = marks[i + 1][1] if i + 1 < len(marks) else len(text)
        yield mid, text[start:end]


def main():
    text = SRC.read_text(encoding="utf-8", errors="replace")

    # authoritative area for chest maps
    map_to_area = {str(c["map"]): AREA_NAMES.get(c["area"], c["area"]) for c in CHESTS}

    map_requires, edges = {}, []
    for mid, body in map_blocks(text):
        # area from setArea(<CONST>) if we don't already know it
        area_m = re.search(r"setArea\(([A-Z0-9_]+)", body)
        if area_m and str(mid) not in map_to_area:
            const = area_m.group(1)
            if const in AREA_NAMES:
                map_to_area[str(mid)] = AREA_NAMES[const]

        reqs = set()
        # initScenes(..., Items.X, true) -> blocking tool gate
        for mm in re.finditer(r"initScenes?\([^;]*?" + ITEM + r"\s*,\s*true", body):
            reqs.add(mm.group(1))
        # initKey(_, Items.X) -> locked door
        for mm in re.finditer(r"initKey\([^,]*,\s*" + ITEM, body):
            reqs.add(mm.group(1))
        if reqs:
            map_requires[str(mid)] = sorted(reqs)

        # best-effort adjacency: door.into = N
        for mm in re.finditer(r"\.into\s*=\s*(\d+)", body):
            edges.append({"from": str(mid), "to": mm.group(1),
                          "requires": sorted(reqs)})

    out = {
        "regions": sorted(set(map_to_area.values())),
        "edges": edges,
        "map_to_area": map_to_area,
        "map_requires": map_requires,
    }
    (REPO / "apworld" / "ebf4" / "data" / "regions.json").write_text(
        json.dumps(out, indent=1))
    print(f"regions={len(out['regions'])} maps={len(map_to_area)} "
          f"gated_maps={len(map_requires)} edges={len(edges)}")
    print("gate items:", sorted({i for v in map_requires.values() for i in v}))


if __name__ == "__main__":
    main()
