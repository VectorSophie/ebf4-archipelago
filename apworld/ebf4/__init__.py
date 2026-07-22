"""Epic Battle Fantasy 4 — Archipelago world.

Treasure chests are locations. The non-consumable tools (axe/candle/hammer/boots/
ladder) are shuffled into the multiworld with region logic guaranteeing every
seed is completable; consumable keys stay vanilla so key-gated content is always
reachable in order. See data.py / regions.py.

The client is a standalone console/tkinter script (ebf4_client.py), not a
Launcher component — the frozen Archipelago Launcher runs a component's func
in-process and Kivy allows one GUI app per process, so an apworld-shipped GUI
client collides with the Launcher.
"""
from BaseClasses import Item, ItemClassification, Location, Region
from worlds.AutoWorld import World, WebWorld

from . import presets
from .data import (FILLER_ITEM, GODCAT_KEY, GODCAT_LOCATION, TRAP_NAMES, areas,
                   battle_locations, bundle_item_names, item_id_to_grant,
                   foe_locations, item_name_to_id, items, location_name_to_id,
                   locations, medal_locations, party_item_names, tool_chest_item,
                   tool_item_names)
from .options import EBF4Options

_CLASSIFICATION = {
    "progression": ItemClassification.progression,
    "useful": ItemClassification.useful,
    "filler": ItemClassification.filler,
    "trap": ItemClassification.trap,
}


class EBF4Item(Item):
    game = "Epic Battle Fantasy 4"


class EBF4Location(Location):
    game = "Epic Battle Fantasy 4"


class EBF4Web(WebWorld):
    theme = "grass"
    rich_text_options_doc = True


class EBF4World(World):
    """Epic Battle Fantasy 4 is a turn-based RPG by Matt Roszak. Its treasure
    chests are shuffled into the multiworld: open a chest to send a check, and
    receive other players' items in return."""

    game = "Epic Battle Fantasy 4"
    web = EBF4Web()
    options: EBF4Options
    options_dataclass = EBF4Options
    item_name_to_id = item_name_to_id
    location_name_to_id = location_name_to_id
    item_name_groups = areas
    required_client_version = (0, 6, 0)
    origin_region_name = "Overworld"

    # ---- setup ----

    def generate_early(self):
        presets.apply(self.options)
        self._starting_tools = []
        n = self.options.starting_tools.value
        if n and self.options.randomize_tools:
            self._starting_tools = self.random.sample(
                tool_item_names, min(n, len(tool_item_names)))
        # which boss battles are active as locations
        if self.options.randomize_bosses:
            self._active_battles = dict(battle_locations)
        elif self.options.goal.current_key == "godcat" and GODCAT_LOCATION:
            self._active_battles = {GODCAT_LOCATION: battle_locations[GODCAT_LOCATION]}
        else:
            self._active_battles = {}
        # medals + bestiary are always filler-only checks (see create_regions)
        self._active_medals = (dict(medal_locations)
                               if self.options.randomize_medals else {})
        self._active_foes = (dict(foe_locations)
                             if self.options.randomize_bestiary else {})

    # ---- items ----

    def create_item(self, name: str) -> EBF4Item:
        cls = _CLASSIFICATION[items[name]["classification"]]
        return EBF4Item(name, cls, item_name_to_id[name], self.player)

    def create_items(self):
        pool = list(bundle_item_names)
        # one reward item per active boss battle (keeps item/location counts equal)
        for d in self._active_battles.values():
            pool.append(f"Battle Reward ({d['map']}-{d['idx']})")
        # one filler reward per active medal / bestiary check
        for d in (*self._active_medals.values(), *self._active_foes.values()):
            pool.append(d["reward"])
        if self.options.randomize_tools:
            # tools go in the pool, shuffled with everything else
            pool += tool_item_names
            # precollect any starting tools; top up the pool with filler so the
            # item/location counts stay balanced
            for tool in self._starting_tools:
                pool.remove(tool)
                self.multiworld.push_precollected(self.create_item(tool))
                pool.append(FILLER_ITEM)
        else:
            # lock each tool to its vanilla chest; only bundles fill the pool
            for loc_name, tool_name in tool_chest_item.items():
                loc = self.multiworld.get_location(loc_name, self.player)
                loc.place_locked_item(self.create_item(tool_name))

        # party members displace filler (progression, but count stays balanced)
        if self.options.party_shuffle:
            filler_pos = [i for i, n in enumerate(pool)
                          if items[n]["classification"] == "filler"]
            for name, i in zip(party_item_names,
                               self.random.sample(filler_pos,
                                                   min(len(party_item_names),
                                                       len(filler_pos)))):
                pool[i] = name

        # replace a share of filler items with traps
        enabled = [TRAP_NAMES[k] for k in self.options.trap_types.value
                   if k in TRAP_NAMES]
        pct = self.options.trap_percentage.value
        if enabled and pct:
            filler_pos = [i for i, n in enumerate(pool)
                          if items[n]["classification"] == "filler"]
            count = len(filler_pos) * pct // 100
            for i in self.random.sample(filler_pos, min(count, len(filler_pos))):
                pool[i] = self.random.choice(enabled)

        self.multiworld.itempool += [self.create_item(n) for n in pool]

    # ---- regions & rules ----

    def create_regions(self):
        region = Region("Overworld", self.player, self.multiworld)
        randomize = bool(self.options.randomize_tools)
        all_locs = {**locations, **self._active_battles}
        for loc_name, loc in all_locs.items():
            location = EBF4Location(self.player, loc_name, loc["id"], region)
            if randomize and loc.get("requires"):
                req = sorted(loc["requires"])
                location.access_rule = \
                    lambda state, r=req: state.has_all(r, self.player)
            region.locations.append(location)

        # medal + bestiary locations: always reachable, but filler-only so no
        # progression can hide behind an achievement/kill that may not be
        # reliably earnable.
        for loc_name, loc in (*self._active_medals.items(), *self._active_foes.items()):
            location = EBF4Location(self.player, loc_name, loc["id"], region)
            location.item_rule = lambda item: not item.advancement
            region.locations.append(location)

        # Phase-1 goal: collect every tool (progression items that gate the final
        # area) = "you can reach Godcat". The real godcat/boss_hunt/check_percent
        # goals arrive with battle checks. Filler/useful items can't gate a goal:
        # AP's reachability sweep only collects progression items.
        goal = EBF4Location(self.player, "Goal", None, region)
        goal_items = list(tool_item_names)
        if self.options.party_shuffle:
            goal_items += party_item_names   # your full party before Godcat
        goal.access_rule = lambda state: state.has_all(goal_items, self.player)
        goal.place_locked_item(
            EBF4Item("Victory", ItemClassification.progression, None, self.player))
        region.locations.append(goal)
        self.multiworld.regions.append(region)

    def set_rules(self):
        self.multiworld.completion_condition[self.player] = \
            lambda state: state.has("Victory", self.player)

    # ---- slot data ----

    def fill_slot_data(self):
        o = self.options
        loc_keys = {d["key"]: d["id"] for d in locations.values()}
        loc_keys.update({d["key"]: d["id"] for d in self._active_battles.values()})
        loc_keys.update({d["key"]: d["id"] for d in self._active_medals.values()})
        loc_keys.update({d["key"]: d["id"] for d in self._active_foes.values()})
        return {
            "location_keys": loc_keys,
            "item_grants": {str(i): g for i, g in item_id_to_grant.items()},
            "goal": o.goal.current_key,
            "goal_location": GODCAT_KEY if o.goal.current_key == "godcat" else "",
            "boss_hunt_count": o.boss_hunt_count.value,
            "check_percentage": o.check_percentage.value,
            "total_locations": len(loc_keys),
            "difficulty": o.difficulty.current_key,
            "party_shuffle": bool(o.party_shuffle.value),
            "in_game_messages": bool(o.in_game_messages.value),
            "death_link": bool(o.death_link.value),
        }
