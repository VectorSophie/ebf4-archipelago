"""Location/item tables for the EBF4 demo world (Greenwood/TOWN1 chests)."""
import json
from pathlib import Path

BASE_ID = 4265610000  # EBF4 Steam appid 265610, namespaced

_chests = json.loads((Path(__file__).parent / "data" / "chests.json").read_text())


def _item_name(contents) -> str:
    parts = []
    for kind, name, qty in contents:
        if kind == "money":
            parts.append(f"{qty} gold")
        elif qty > 1:
            parts.append(f"{qty}x {name}")
        else:
            parts.append(name)
    return "EBF4: " + " + ".join(parts)


# one location and one item (its vanilla content bundle) per chest
locations = {}   # AP location name -> dict(id, key, map, chest)
items = {}       # AP item name -> dict(id, grant)
for n, c in enumerate(_chests):
    loc_name = f"Greenwood Chest {c['map']}-{c['chest']}"
    key = f"chest_{c['map']}_{c['chest']}"
    locations[loc_name] = {"id": BASE_ID + n, "key": key,
                           "map": c["map"], "chest": c["chest"]}
    item_name = _item_name(c["contents"])
    while item_name in items:  # identical bundles would collide; disambiguate
        item_name += " *"
    items[item_name] = {"id": BASE_ID + n, "grant": c["contents"]}

location_name_to_id = {n: d["id"] for n, d in locations.items()}
item_name_to_id = {n: d["id"] for n, d in items.items()}
location_key_to_id = {d["key"]: d["id"] for d in locations.values()}
item_id_to_grant = {d["id"]: d["grant"] for d in items.values()}
