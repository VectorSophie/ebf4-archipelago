from dataclasses import dataclass

from Options import DeathLink, PerGameCommonOptions, Range

from .data import chests


class ChestsRequired(Range):
    """How many treasure bundles you must collect to win. Lower it for a shorter
    game. Defaults to every chest in the pool."""
    display_name = "Chests Required to Win"
    range_start = 1
    range_end = len(chests)
    default = len(chests)


@dataclass
class EBF4Options(PerGameCommonOptions):
    chests_required: ChestsRequired
    death_link: DeathLink
