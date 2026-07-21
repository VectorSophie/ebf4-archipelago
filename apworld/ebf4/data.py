"""Location/item tables for the EBF4 world.

Locations are the game's treasure chests. Two families of gating item exist:

* **Tools** (axe/candle/hammer/leafyboots/stepladder/thermalboots/wingedboots) —
  non-consumable binary gates. These are shuffled into the multiworld when
  `randomize_tools` is on, and region logic (`regions.py`) requires them.
* **Keys** (copper/steel/gold/coral) — *consumable* (each locked door eats one),
  which makes clean logic hard. They stay in their vanilla chests, so key-gated
  content is always reachable in vanilla order. Their chests are therefore never
  AP locations. (Shuffling keys with proper counted logic is future work — see
  the `progressive_keys` option.)

Item classification: tool items are `progression`; equipment/spell bundles are
`useful`; pure gold/consumable bundles are `filler`. Traps live in traps.py.
"""
import json
import pkgutil

from . import regions

BASE_ID = 4265610000  # EBF4 Steam appid 265610, namespaced

# non-consumable tools we shuffle + gate on
SHUFFLE_TOOLS = {
    "axe", "candle", "hammer", "leafyboots", "stepladder",
    "thermalboots", "wingedboots",
}
# consumable keys: kept vanilla, their chests are not AP locations
KEYS = {"copperkey", "coralkey", "goldkey", "steelkey"}

TOOL_NAMES = {
    "axe": "Axe", "candle": "Candle", "hammer": "Hammer",
    "leafyboots": "Leafy Boots", "stepladder": "Step Ladder",
    "thermalboots": "Thermal Boots", "wingedboots": "Winged Boots",
}

_all_chests = json.loads(pkgutil.get_data(__package__, "data/chests.json").decode("utf-8"))


def _has(chest, names):
    return any(n in names for _k, n, _q in chest["contents"])


# chests that are AP locations = everything except key chests
chest_locations = [c for c in _all_chests if not _has(c, KEYS)]
# of those, the ones that hold a shuffled tool (their item becomes the tool)
_tool_chests = [c for c in chest_locations if _has(c, SHUFFLE_TOOLS)]
_bundle_chests = [c for c in chest_locations if not _has(c, SHUFFLE_TOOLS)]


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


def _classify(contents) -> str:
    # equipment ('e') or spell ('s') present -> useful; else filler
    if any(k in ("e", "s") for k, _n, _q in contents):
        return "useful"
    return "filler"


AREA_NAMES = {
    "TOWN1": "Greenwood", "GRAVEYARD": "Graveyard", "ASHWOOD": "Ashwood Forest",
    "CAVERNS": "Crystal Caverns", "TOWN2": "Whitefall Town", "FACTORY": "The Kitten Kaboodle",
    "JUNGLE": "Lankyroot Jungle", "TOWN3": "Redpine Town", "TEMPLE": "Temple of Godcat",
    "EXTRA": "Battle Mountain",
}


def _tool_of(chest):
    for _k, n, _q in chest["contents"]:
        if n in SHUFFLE_TOOLS:
            return n
    return None


# ---- build the static registries (superset; independent of options) ----

# locations: every non-key chest. name/key/id stable in chests.json order.
# Requirement model is ENTRY-ONLY: a location requires the tools that gate the
# areas *before* its own (from regions.area_entry_requirements). An area's own
# internal tool gates are deliberately NOT added — doing so would require a tool
# to reach the very chests that hold it (a fill deadlock). Tools found in an area
# gate every *later* area, which is what matters for progression; rare intra-area
# sub-gates are covered by the client's /tool failsafe.
_ENTRY = regions.area_entry_requirements()
locations = {}          # AP location name -> dict(id, key, map, chest, area, requires)
for n, c in enumerate(chest_locations):
    area = AREA_NAMES.get(c["area"], c["area"])
    loc_name = f"{area} Chest {c['map']}-{c['chest']}"
    key = f"chest_{c['map']}_{c['chest']}"
    req = {TOOL_NAMES[t] for t in _ENTRY.get(area, set()) if t in SHUFFLE_TOOLS}
    locations[loc_name] = {"id": BASE_ID + n, "key": key, "map": c["map"],
                           "chest": c["chest"], "area": area, "requires": req}

# items: one bundle item per non-tool chest + one tool item per tool chest.
# item ids continue after the location id block so item/location ids don't clash
# on grant lookups (grants are keyed by item id).
ITEM_BASE = BASE_ID + 100000
items = {}              # AP item name -> dict(id, grant, classification)


def _add_item(name, grant, classification):
    if name not in items:
        items[name] = {"id": ITEM_BASE + len(items), "grant": grant,
                       "classification": classification}


# tool items (progression). grant just the tool.
for raw, disp in TOOL_NAMES.items():
    _add_item(disp, [["i", raw, 1]], "progression")

# a generic filler used to top up the pool when items are precollected
# (starting_tools) or replaced by traps.
FILLER_ITEM = "Gold Pouch"
_add_item(FILLER_ITEM, [["money", "", 500]], "filler")

# trap items: grant kind "trap" with a subkind the mod applies as a bad effect.
TRAP_NAMES = {
    "poison": "Poison Trap", "goldloss": "Gold Loss Trap",
    "encounter": "Encounter Trap", "statdown": "Stat Down Trap",
}
for _kind, _name in TRAP_NAMES.items():
    _add_item(_name, [["trap", _kind, 0]], "trap")

# bundle items (one per non-tool chest); name carries (map-chest) so it's unique.
for c in _bundle_chests:
    name = f"{_label(c['contents'])} ({c['map']}-{c['chest']})"
    _add_item(name, c["contents"], _classify(c["contents"]))

# ---- battle (boss) locations + reward items ----
# non-respawnable battles become locations; each gets a filler reward item.
_battles = regions._data.get("battles", {})
GODCAT_KEY = "battle_97_0"          # final boss = the godcat goal location
battle_locations = {}               # loc name -> dict(id, key, map, idx, area, requires)
BATTLE_ID_BASE = BASE_ID + 1000
_bi = 0
for _mid, _blist in _battles.items():
    _area = regions.map_area(_mid)
    if _area is None:
        continue
    for _b in _blist:
        if _b["respawn"]:
            continue
        key = f"battle_{_mid}_{_b['idx']}"
        loc_name = f"{_area} Battle {_mid}-{_b['idx']}"
        req = {TOOL_NAMES[t] for t in _ENTRY.get(_area, set()) if t in SHUFFLE_TOOLS}
        battle_locations[loc_name] = {
            "id": BATTLE_ID_BASE + _bi, "key": key, "map": int(_mid),
            "idx": _b["idx"], "area": _area, "requires": req, "name": _b["name"]}
        _bi += 1
        _add_item(f"Battle Reward ({_mid}-{_b['idx']})", [["money", "", 800]], "filler")

# name of the godcat goal location (may be absent if map 97 not parsed)
GODCAT_LOCATION = next((n for n, d in battle_locations.items()
                        if d["key"] == GODCAT_KEY), None)
battle_reward_names = [f"Battle Reward ({d['map']}-{d['idx']})"
                       for d in battle_locations.values()]

# ---- medal (achievement) locations + filler rewards ----
# Earning an in-game medal is a check. Medals are always filler-only (see the
# item_rule in __init__): some medals aren't reliably earnable (epic aces,
# online/social, "collect every summon"), so no progression may hide behind one.
_medals = json.loads(pkgutil.get_data(__package__, "data/medals.json").decode("utf-8"))
MEDAL_ID_BASE = BASE_ID + 2000
medal_locations = {}                # loc name -> dict(id, key, reward)
_seen_medal_names = set()
for _mi, (_mid, _mname) in enumerate(_medals.items()):
    loc_name = f"Medal: {_mname}"
    if loc_name in _seen_medal_names:
        loc_name = f"Medal: {_mname} ({_mid})"
    _seen_medal_names.add(loc_name)
    reward = f"Medal Reward ({_mid})"
    medal_locations[loc_name] = {"id": MEDAL_ID_BASE + _mi, "key": f"medal_{_mid}",
                                 "reward": reward}
    _add_item(reward, [["money", "", 300]], "filler")

# maps AP code needs
_all_locs = {**locations, **battle_locations, **medal_locations}
location_name_to_id = {n: d["id"] for n, d in _all_locs.items()}
item_name_to_id = {n: d["id"] for n, d in items.items()}
location_key_to_id = {d["key"]: d["id"] for d in _all_locs.values()}
item_id_to_grant = {d["id"]: d["grant"] for d in items.values()}

# which item name each tool chest should hold when tools are locked to vanilla
# (randomize_tools off): chest location name -> tool item name
tool_chest_item = {}
for c in _tool_chests:
    area = AREA_NAMES.get(c["area"], c["area"])
    loc_name = f"{area} Chest {c['map']}-{c['chest']}"
    tool_chest_item[loc_name] = TOOL_NAMES[_tool_of(c)]

# the bundle items that make up the fillable pool (everything except tool items)
bundle_item_names = [f"{_label(c['contents'])} ({c['map']}-{c['chest']})" for c in _bundle_chests]
tool_item_names = list(TOOL_NAMES.values())

# group locations by area (item-name groups / loose grouping)
areas = {}
for name, d in locations.items():
    areas.setdefault(d["area"], []).append(name)
