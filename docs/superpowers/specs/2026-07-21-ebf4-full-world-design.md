# EBF4 Archipelago — Full World Design

Turn the EBF4 apworld from a flat 430-chest overlay into a competent Archipelago
world: real region logic, multiple check families, meaningful item pool, a
game-shaped goal, and EBF4-specific polish. Ships in phases, each independently
playable and testable.

Status: approved 2026-07-21. Supersedes the flat-logic model of v1.1.0.

## Goals

- A seed is provably completable by AP's fill solver (no soft-locks), with
  progression tools/keys shuffled into the multiworld.
- Checks beyond chests: battles/bosses, medals, first-defeat bestiary.
- A real win condition (beat Godcat) with alternatives.
- Safe defaults: a cautious player gets a working game; opt-in depth for the rest.
- No new game *assets* shipped; all mod code stays as `AP_*` statics + hooks,
  patched into the user's own SWF (unchanged distribution model).

## Non-goals

- No PopTracker pack / extra links / plando in the first two phases (phase 3).
- No rebalancing of EBF4 combat or economy.
- No support for non-Steam builds.

## Grounding (verified in `reference/ebf4-decompile`)

- **Gating is data-driven.** `MapData.as` uses `initScenes(scenes, dialogue,
  idx, _, Items.<tool>, true)` for blocking tool gates and `initKey(n,
  Items.<key>)` for locked doors. Map adjacency comes from `door.into` targets
  and `Maps.warpData[]`.
- **Battles.** `Game.endBattle()` computes id `"M"+mapNo+"_B"+battleNo` and sets
  `Maps.foeData[mapNo][battleNo]=2` on win (`3` if respawnable). Persisted in
  saves. One hook covers all battle checks.
- **Final boss.** `Battles.godcat` is the endgame fight.
- **Medals.** `Medals.as` defines ~35 named achievements (`treasurehunter`,
  `beastmaster`, `quest1..3`, `zoostudent`, …) unlocked via `Medals.saveMisc()`.
- **Bestiary.** `Foes.scannedFoes` (scanned) and `SaveData.foesDefeated` (count)
  exist; first-defeat-*per-type* is not tracked and must be added mod-side.

## Data model

Locations keep today's key convention `type_map_idx` and the `BASE_ID`
(4265610000) numbering, extended with new families:

| Family    | Key             | Source                                   |
|-----------|-----------------|------------------------------------------|
| `chest_*` | `chest_<m>_<i>` | existing `chests.json` (430)             |
| `battle_*`| `battle_<m>_<b>`| `endBattle` win, `M<m>_B<b>`             |
| `medal_*` | `medal_<name>`  | `Medals` unlock                          |
| `foe_*`   | `foe_<id>`      | first defeat of a foe type (mod-tracked) |

Items: each location's vanilla contents remains its item (grant list as today),
plus shuffled **tools/keys**, **traps**, and **filler**. Every item is tagged
`progression | useful | filler | trap` in `data.py` so it places well in other
players' worlds. Tools/keys are `progression`; traps are `trap`; gold/consumable
bundles default `filler`, gear/skills `useful`.

## Regions & logic

- **`tools/extract_map.py`** parses `MapData.as` → `data/regions.json`:
  `{regions: [...], edges: [{from, to, requires: [item,...]}], map_to_area: {...}}`.
  Logic is generated data, mirroring `extract_chests.py`.
- **Primary model:** map-level regions with extracted door/warp adjacency and
  per-edge item requirements, grouped under the existing area names.
- **Fallback model** (if adjacency parsing proves noisy): area-level regions,
  each gated on the *cumulative* set of items required to traverse to it. This is
  conservative — it can only *under*-promise reachability — so it stays
  soft-lock-safe. The extractor emits both; `__init__.py` picks primary, falls
  back per-region on missing data.
- Access rules use `state.has_all(requires, player)`. Chest/battle/medal/foe
  locations attach to the region they occur in.
- When `randomize_tools` is **off**, tools/keys are removed from the pool and
  left in their vanilla chests; all regions collapse to always-reachable (today's
  behavior) — logic code still runs but every rule is trivially satisfied.

## Options (`options.py`)

| Option | Type | Default | Notes |
|---|---|---|---|
| `preset` | Choice | `order` | `order` \| `chaos` \| `custom` (see Presets) |
| `randomize_tools` | Toggle | on | off = vanilla tools, flat logic |
| `goal` | Choice | `godcat` | `godcat` \| `boss_hunt` \| `check_percent` |
| `boss_hunt_count` | Range | 10 | used when goal=`boss_hunt` |
| `check_percentage` | Range 1–100 | 100 | used when goal=`check_percent` |
| `randomize_bosses` | Toggle | on | battle checks |
| `randomize_medals` | Toggle | on | medal checks |
| `randomize_bestiary` | Toggle | on | first-defeat checks |
| `trap_percentage` | Range 0–40 | 10 | share of filler replaced by traps |
| `difficulty` | Choice | `normal` | start run on easy/normal/hard/epic |
| `in_game_messages` | Toggle | on | on-screen banner toasts for major events (see below) |
| `death_link` | DeathLink | off | existing |

## Presets

A `preset` Choice option (default `order`) sets a bundle of the options above so a
player picks a vibe instead of tuning each knob. An explicitly-set option in the
YAML always overrides the preset (preset fills only the unset ones).

| Option | `order` (default) | `chaos` |
|---|---|---|
| feel | structured completionist | trap gauntlet |
| `goal` | `godcat` | `check_percent` |
| `check_percentage` | 100 | 40 |
| `trap_percentage` | 10 | 40 |
| trap weighting | even | toward `encounter` / `statdown` |
| `death_link` | off | on |
| `difficulty` | `normal` | `hard` |
| everything-on checks | yes | yes |

`custom` leaves every option at its own default and lets the YAML drive. Presets
never change logic integrity — `chaos` is still solver-guaranteed completable; it
only makes the ride rougher.

## Goal

The Godcat win is a `battle_` location. `goal=godcat` sets the completion
condition to that location (its `place_locked_item(Victory)`). `boss_hunt` sets
completion to "N distinct `battle_` items collected"; `check_percent` to "N% of
all locations checked". Only the completion condition changes — no game-side
difference; the game always just reports battle wins.

## Mod changes (`gamemod/scripts/`)

- `Game.as` `endBattle` hook → send `{type:"check", location:"battle_<m>_<b>"}`
  for managed battles (idempotent via `foeData` state, same pattern as chests).
- `Game.as` medal-unlock hook → `medal_<name>` check.
- New mod-side set `AP_state.data.foesKilled` in `EBF4AP.sol`; on first defeat of
  a foe type, send `foe_<id>` (only when `randomize_bestiary`).
- `AP_applyItem` extended grant kinds: `poison`, `goldloss`, `encounter`,
  `statdown` (traps); `tool`/`key` already grant via `Items[...]`.
- All new hooks wrapped in try/catch; suppress managed locations' vanilla effects
  only (as chests do now); vanilla behavior intact when disconnected.

## Client changes (`ebf4_client.py`)

- Handle new location families (same check plumbing; the server already knows
  the ids from slot_data `location_keys`).
- Re-add `LocationScouts` on connect so the client knows what each chest holds.
- **Banner overlay for major events.** The existing black banner HUD (`{type:"msg"}`
  toast, added to `root.stage`) becomes the channel for every notable event, all
  gated by the `in_game_messages` option (default on, read from slot_data):
  - `Sent <item> to <player>` — opened a chest holding another player's item
  - `Received <item> from <player>` — incoming multiworld item
  - `Got <tool/key>!` — a progression tool/key arrived (highlighted style)
  - `<player> was defeated` — DeathLink in/out
  - `Trap: <name>` — a trap resolved
  - `Boss defeated: <name>` / goal-progress ticks (e.g. `12/50 chests`)
  - `Connected` / `Reconnecting…` — link status changes
  - `GOAL! You win!` — completion
  The client sends these as `msg` frames; when `in_game_messages` is off it
  suppresses them (item delivery and the vanilla treasure popup still happen).
- `/tool <name>` command: hand-grant a tool as an `item` frame (stuck failsafe).
- Goal detection unchanged (fires on the goal location / condition).

## Phasing

- **Phase 1 — competent world:** `extract_map.py` + region logic +
  `randomize_tools` + battle/boss checks + configurable goal + item
  classification + traps + scouts + `/tool`. A real AP world on its own.
- **Phase 2 — EBF4 flavor:** medal + bestiary checks, summon/quest items,
  difficulty/party options.
- **Phase 3 — nice-to-have:** PopTracker pack, extra links, plando.

Phasing is **build order only, not opt-in**: every feature ships enabled by
default, including the ones originally marked optional (medals, bestiary,
summon/quest items, difficulty/party). Each phase bumps `world_version`,
rebuilds the dist bundle, and updates SETUP/README. Toggles still exist so a
player can turn a family *off*, but the default run has everything on.

## Testing

- `tools/test_logic.py` (headless, no framework): for both `randomize_tools`
  states and many seeds, assert the fill solver completes and every region is
  reachable; assert `goal` variants set a satisfiable completion condition.
- Extend the mock-game harness to exercise `battle_`, `medal_`, `foe_` checks
  and each trap grant kind.
- One live smoke test per phase on the real patched game (File 7).

## Risks

- **Map-modeling gaps** → the `/tool` failsafe + `randomize_tools:false` default-
  safe path cover a mis-modeled gate; `test_logic.py` catches most before ship.
- **Bestiary tracking** is the heaviest hook (new persisted state); it is
  optional and phase 2, so phase 1 is unaffected.
- **Save compatibility:** new `EBF4AP.sol` fields are additive and seed-scoped;
  never touch `EBF4_*.meow` game saves.
