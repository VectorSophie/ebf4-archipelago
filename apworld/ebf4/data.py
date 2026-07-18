"""Location/item tables for the EBF4 world.

Locations are the game's treasure chests. Chests whose vanilla contents include a
progression-gating item (keys, axe, candle, hammer, boots) are left OUT of the
shuffle so those tools stay in their vanilla spots — that keeps every area
reachable in vanilla order, so the world needs no item logic and can never
produce an impossible seed.
"""
import json
import pkgutil

BASE_ID = 4265610000  # EBF4 Steam appid 265610, namespaced

# items that gate movement/doors (initScenes required-item + initKey). Any chest
# containing one of these is kept vanilla and is not an AP location.
GATING_ITEMS = {
    "axe", "candle", "hammer", "leafyboots", "stepladder",
    "thermalboots", "wingedboots",
    "copperkey", "coralkey", "goldkey", "steelkey",
}

# pkgutil.get_data works whether the world is an unpacked dir or a zipped .apworld
_all_chests = json.loads(pkgutil.get_data(__package__, "data/chests.json").decode("utf-8"))


def _is_gating(chest) -> bool:
    return any(name in GATING_ITEMS for kind, name, qty in chest["contents"])


# the shuffleable chests, in map order (stable ids)
chests = [c for c in _all_chests if not _is_gating(c)]


def _label(contents) -> str:
    parts = []
    for kind, name, qty in contents:
        if kind == "money":
            parts.append(f"{qty} gold")
        elif qty > 1:
            parts.append(f"{qty}x {name}")
        else:
            parts.append(name)
    return " + ".join(parts) if parts else "nothing"


AREA_NAMES = {
    "TOWN1": "Greenwood", "GRAVEYARD": "Graveyard", "ASHWOOD": "Ashwood Forest",
    "CAVERNS": "Crystal Caverns", "TOWN2": "Whitefall Town", "FACTORY": "The Kitten Kaboodle",
    "JUNGLE": "Lankyroot Jungle", "TOWN3": "Redpine Town", "TEMPLE": "Temple of Godcat",
    "EXTRA": "Battle Mountain",
}

# one location and one item (its vanilla content bundle) per shuffleable chest.
locations = {}   # AP location name -> dict(id, key, map, chest, area)
items = {}       # AP item name -> dict(id, grant)
for n, c in enumerate(chests):
    area = AREA_NAMES.get(c["area"], c["area"])
    loc_name = f"{area} Chest {c['map']}-{c['chest']}"
    key = f"chest_{c['map']}_{c['chest']}"
    locations[loc_name] = {"id": BASE_ID + n, "key": key, "map": c["map"],
                           "chest": c["chest"], "area": area}
    item_name = f"{_label(c['contents'])} ({c['map']}-{c['chest']})"
    items[item_name] = {"id": BASE_ID + n, "grant": c["contents"]}

location_name_to_id = {n: d["id"] for n, d in locations.items()}
item_name_to_id = {n: d["id"] for n, d in items.items()}
location_key_to_id = {d["key"]: d["id"] for d in locations.values()}
item_id_to_grant = {d["id"]: d["grant"] for d in items.values()}

# group locations by area (for regions and item-name groups)
areas = {}
for name, d in locations.items():
    areas.setdefault(d["area"], []).append(name)
