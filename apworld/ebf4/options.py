from dataclasses import dataclass

from Options import (Choice, DeathLink, DefaultOnToggle, OptionSet,
                     PerGameCommonOptions, Range, Toggle)

from .data import tool_item_names


class Preset(Choice):
    """Pick a vibe instead of tuning every knob. `order` = the curated,
    structured completionist run (the default). `chaos` = a trap gauntlet
    (short percentage goal, lots of traps, DeathLink, harder). `custom` = leave
    every option at its own value. Any option you set explicitly always wins."""
    display_name = "Preset"
    option_order = 0
    option_chaos = 1
    option_custom = 2
    default = 0


class Goal(Choice):
    """How you win. `godcat` = reach and beat the final boss. `boss_hunt` = defeat
    a number of bosses. `check_percent` = check a percentage of all locations."""
    display_name = "Goal"
    option_godcat = 0
    option_boss_hunt = 1
    option_check_percent = 2
    default = 0


class BossHuntCount(Range):
    """Bosses to defeat when goal is boss_hunt."""
    display_name = "Boss Hunt Count"
    range_start = 1
    range_end = 30
    default = 10


class CheckPercentage(Range):
    """Percent of locations to check when goal is check_percent."""
    display_name = "Check Percentage"
    range_start = 1
    range_end = 100
    default = 100


class RandomizeTools(DefaultOnToggle):
    """Shuffle the game's non-consumable tools (axe, candle, hammer, and the
    boots/ladder) into the multiworld, with region logic that guarantees every
    seed is completable. Turn OFF to leave the tools in their vanilla chests
    (no traversal logic — the safe, flat experience). Keys always stay vanilla."""
    display_name = "Randomize Tools"


class RandomizeBosses(DefaultOnToggle):
    """Defeating a scripted battle/boss is a location check."""
    display_name = "Randomize Bosses"


class RandomizeMedals(DefaultOnToggle):
    """Earning an in-game medal (achievement) is a location check."""
    display_name = "Randomize Medals"


class RandomizeBestiary(DefaultOnToggle):
    """The first time you defeat each foe type is a location check."""
    display_name = "Randomize Bestiary"


class StartingTools(Range):
    """Begin with this many random tools already in hand (eases the opening)."""
    display_name = "Starting Tools"
    range_start = 0
    range_end = len(tool_item_names)
    default = 0


class PartyShuffle(Toggle):
    """Shuffle your party into the multiworld. You start solo as Anna; Matt,
    Natalie, and Lance become items you receive from other players (they no
    longer auto-join at their story moments). Off = vanilla: the party joins as
    the story dictates. When on, the three are progression and guaranteed before
    the final boss. Note: until an ally's item arrives you fight understaffed
    (an intended difficulty spike, not a soft-lock)."""
    display_name = "Party Shuffle"


class TrapPercentage(Range):
    """Percent of filler items replaced by traps."""
    display_name = "Trap Percentage"
    range_start = 0
    range_end = 40
    default = 10


class TrapTypes(OptionSet):
    """Which traps may appear."""
    display_name = "Trap Types"
    valid_keys = {"poison", "goldloss", "encounter", "statdown"}
    default = frozenset({"poison", "goldloss", "encounter", "statdown"})


class Difficulty(Choice):
    """Difficulty the run starts on."""
    display_name = "Difficulty"
    option_easy = 0
    option_normal = 1
    option_hard = 2
    option_epic = 3
    default = 1


class InGameMessages(DefaultOnToggle):
    """Show the on-screen banner overlay for major events (items sent/received,
    tools, DeathLink, traps, bosses, goal, link status)."""
    display_name = "In-Game Messages"


@dataclass
class EBF4Options(PerGameCommonOptions):
    preset: Preset
    goal: Goal
    boss_hunt_count: BossHuntCount
    check_percentage: CheckPercentage
    randomize_tools: RandomizeTools
    randomize_bosses: RandomizeBosses
    randomize_medals: RandomizeMedals
    randomize_bestiary: RandomizeBestiary
    starting_tools: StartingTools
    party_shuffle: PartyShuffle
    trap_percentage: TrapPercentage
    trap_types: TrapTypes
    difficulty: Difficulty
    in_game_messages: InGameMessages
    death_link: DeathLink
