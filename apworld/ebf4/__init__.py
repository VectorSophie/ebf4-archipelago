"""Epic Battle Fantasy 4 — Archipelago world.

Every treasure chest (except the few holding progression tools/keys, which stay
vanilla) is a location; its vanilla contents become a shuffled item bundle. No
item logic is required because the tools that gate areas are never shuffled, so
all chests are always reachable by normal play."""
from BaseClasses import Item, ItemClassification, Location, Region
from worlds.AutoWorld import World, WebWorld

from .data import (areas, item_id_to_grant, item_name_to_id,
                   location_name_to_id, locations)
from .options import EBF4Options

# The client is a standalone console script (ebf4_client.py in the player bundle),
# not a Launcher component: the frozen Archipelago release runs a component's
# func inside the Launcher's own process, and Kivy allows only one GUI app per
# process, so an apworld-shipped GUI client collides with the Launcher.


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
    item_name_groups = areas  # area name -> location names doubles as loose grouping
    required_client_version = (0, 6, 0)
    origin_region_name = "Overworld"

    def create_item(self, name: str) -> EBF4Item:
        return EBF4Item(name, ItemClassification.progression,
                        item_name_to_id[name], self.player)

    def create_regions(self):
        region = Region("Overworld", self.player, self.multiworld)
        for loc_name, loc in locations.items():
            region.locations.append(
                EBF4Location(self.player, loc_name, loc["id"], region))
        goal = EBF4Location(self.player, "Goal", None, region)
        required = self.options.chests_required.value
        goal.access_rule = lambda state, n=required: \
            state.has_from_list_unique(item_name_to_id.keys(), self.player, n)
        goal.place_locked_item(
            EBF4Item("Victory", ItemClassification.progression, None, self.player))
        region.locations.append(goal)
        self.multiworld.regions.append(region)

    def create_items(self):
        self.multiworld.itempool += [self.create_item(n) for n in item_name_to_id]

    def set_rules(self):
        self.multiworld.completion_condition[self.player] = \
            lambda state: state.has("Victory", self.player)

    def fill_slot_data(self):
        return {
            "location_keys": {d["key"]: d["id"] for d in locations.values()},
            "item_grants": {str(i): g for i, g in item_id_to_grant.items()},
            "goal_count": self.options.chests_required.value,
            "death_link": bool(self.options.death_link.value),
        }
