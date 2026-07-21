from dataclasses import dataclass

from Options import DeathLink, DefaultOnToggle, PerGameCommonOptions


class RandomizeTools(DefaultOnToggle):
    """Shuffle the game's non-consumable tools (axe, candle, hammer, and the
    boots/ladder) into the multiworld, with region logic that guarantees every
    seed is completable. Turn OFF to leave the tools in their vanilla chests
    (no traversal logic — the safe, flat experience). Keys always stay vanilla."""
    display_name = "Randomize Tools"


@dataclass
class EBF4Options(PerGameCommonOptions):
    randomize_tools: RandomizeTools
    death_link: DeathLink
