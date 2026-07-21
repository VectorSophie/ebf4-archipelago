"""EBF4 region logic derived from data/regions.json.

Model (conservative, soft-lock-safe):
  - Areas progress in the canonical vanilla order (AREA_ORDER).
  - To *enter* an area you need every gate item found in *earlier* areas
    (`area_entry_requirements`). This over-approximates the true main-path gates
    (it also folds in side-area gates), which only ever *over*-gates — never
    under-gates — so it cannot create an impossible seed by omission.
  - A specific location additionally needs its own map's gate items
    (`location_requires`), so e.g. the axe-gated bush inside Greenwood requires
    the axe even though Greenwood is the start area.

The fill solver is the final arbiter: if AREA_ORDER were mis-ordered in a way
that under-gates, generation fails loudly (tools/test_logic.py catches it).
"""
import json
import pathlib
import pkgutil


def _load_regions():
    # pkgutil works inside a zipped .apworld; the filesystem fallback keeps the
    # module importable standalone (headless tests, unpacked checkout).
    try:
        raw = pkgutil.get_data(__package__, "data/regions.json")
        if raw:
            return json.loads(raw.decode("utf-8"))
    except Exception:
        pass
    return json.loads((pathlib.Path(__file__).parent / "data" / "regions.json").read_text())


_data = _load_regions()

# canonical vanilla progression; side areas (Graveyard, Battle Mountain) placed
# where they unlock. Battle Mountain (EXTRA) is post-game -> last.
AREA_ORDER = [
    "Greenwood", "Ashwood Forest", "Graveyard", "Crystal Caverns",
    "Whitefall Town", "The Kitten Kaboodle", "Lankyroot Jungle",
    "Redpine Town", "Temple of Godcat", "Battle Mountain",
]


def _area_gates():
    gates = {a: set() for a in AREA_ORDER}
    for mid, area in _data["map_to_area"].items():
        gates.setdefault(area, set()).update(_data["map_requires"].get(mid, []))
    return gates


def area_entry_requirements():
    """area -> set of items needed to ENTER it (gates from all earlier areas)."""
    gates = _area_gates()
    entry, acc = {}, set()
    for a in AREA_ORDER:
        entry[a] = set(acc)
        acc |= gates.get(a, set())
    return entry


_ENTRY = area_entry_requirements()


def location_requires(map_id):
    """Items required to reach a location on the given map."""
    area = _data["map_to_area"].get(str(map_id))
    own = set(_data["map_requires"].get(str(map_id), []))
    return (_ENTRY.get(area, set()) if area else set()) | own


def map_area(map_id):
    return _data["map_to_area"].get(str(map_id))
