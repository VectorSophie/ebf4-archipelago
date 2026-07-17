"""Epic Battle Fantasy 4 — Archipelago world (demo scope: Greenwood chests)."""
from BaseClasses import Item, ItemClassification, Location, Region
from worlds.AutoWorld import World

from .data import item_id_to_grant, item_name_to_id, location_name_to_id, locations


class EBF4Item(Item):
    game = "Epic Battle Fantasy 4"


class EBF4Location(Location):
    game = "Epic Battle Fantasy 4"


class EBF4World(World):
    """Epic Battle Fantasy 4 is a turn-based RPG by Matt Roszak. Demo world:
    the 20 treasure chests of Greenwood Village are location checks, and their
    vanilla contents are shuffled into the multiworld as item bundles."""

    game = "Epic Battle Fantasy 4"
    item_name_to_id = item_name_to_id
    location_name_to_id = location_name_to_id
    required_client_version = (0, 6, 0)
    origin_region_name = "Greenwood"

    def create_item(self, name: str) -> EBF4Item:
        # every bundle is progression: the goal is collecting all of them
        return EBF4Item(name, ItemClassification.progression, item_name_to_id[name], self.player)

    def create_regions(self):
        region = Region("Greenwood", self.player, self.multiworld)
        for loc_name, loc in locations.items():
            region.locations.append(
                EBF4Location(self.player, loc_name, loc["id"], region))
        # goal event: hold every bundle
        goal = EBF4Location(self.player, "Greenwood Complete", None, region)
        goal.access_rule = lambda state: state.has_all(item_name_to_id.keys(), self.player)
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
        # game/bridge data: which locations are AP-managed, and what each item grants
        return {
            "location_keys": {d["key"]: d["id"] for d in locations.values()},
            "item_grants": {str(i): g for i, g in item_id_to_grant.items()},
        }
