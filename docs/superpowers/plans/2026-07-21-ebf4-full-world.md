# EBF4 Full World Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the flat 430-chest EBF4 apworld into a competent Archipelago world — real region logic with shuffled tools, battle/medal/bestiary/secret checks, a configurable goal, order/chaos presets, ~15 player options behind a zero-config default, a banner overlay for major events, and a standalone tkinter client — shipped as v2.0.0.

**Architecture:** Logic is *generated data*: `extract_map.py` parses the decompiled `MapData.as` into `data/regions.json`; the world builds regions/edges from it. New check families reuse the existing chest hook pattern in the SWF (`endBattle`, medal-unlock, foe-defeat, secret hooks). The client stays a standalone process (tkinter GUI or console), never a Launcher component. Everything defaults on; a `preset` bundles the knobs.

**Tech Stack:** Python 3.10+ (world + client + extractors + tests), Archipelago 0.6.x world API, ActionScript 3 (mod hooks patched via FFDec), tkinter (stdlib GUI), `websockets` (client).

**Reference sources (read-only):** `reference/ebf4-decompile/scripts/default_package/` — `MapData.as` (gating/adjacency), `Game.as` (`endBattle`), `Medals.as`, `Foes.as`, `SaveData.as`.

**Testing:** headless pytest-free asserts (`python tools/test_*.py`) for extraction + logic + solver; the existing mock-game harness for wire/checks; one live patched-game smoke test per phase (File 7 only — never File 1).

**Release discipline:** commit locally after each task; **do not `git push` or tag until the user verifies 2.0.0.**

---

## File structure

**New:**
- `tools/extract_map.py` — parse `MapData.as` → `data/regions.json`
- `apworld/ebf4/data/regions.json` — generated region graph
- `apworld/ebf4/regions.py` — load regions.json, build region/edge/access-rule structures
- `apworld/ebf4/traps.py` — trap item definitions + weighting
- `apworld/ebf4/presets.py` — order/chaos preset → option defaults
- `tools/test_extract.py`, `tools/test_logic.py`, `tools/test_client.py` — headless tests
- `ebf4_client_gui.py` — tkinter front end (imported by `ebf4_client.py`)

**Modified:**
- `apworld/ebf4/data.py` — add battle/medal/foe/secret locations, item classification, progressive keys, chest_contents modes
- `apworld/ebf4/options.py` — all new options + preset
- `apworld/ebf4/__init__.py` — region-based `create_regions`, goal variants, `fill_slot_data` additions, start_inventory for `starting_tools`
- `apworld/ebf4/archipelago.json` — version bumps
- `ebf4_client.py` — GUI/console split, new location families, banner events, `/tool`, scouts
- `gamemod/scripts/Game.as` — endBattle/medal/foe/secret hooks, trap grant kinds, encounter_rate, in_game_messages gate
- `gamemod/scripts/Battle.as` — (already hooks gameover) confirm boss id capture
- `ebf4_example.yaml`, `SETUP.md`, `README.md` — casual-first docs
- `tools/make_dist.py` — bundle new client files + `.pyw`

---

# PHASE 1 — Competent world (v1.2.0 internal milestone)

Region logic + tool shuffle + battle checks + configurable goal + classification + traps + scouts + tkinter client. This alone is a real AP world.

## Task 1: Extract the region graph

**Files:**
- Create: `tools/extract_map.py`
- Create (generated): `apworld/ebf4/data/regions.json`
- Test: `tools/test_extract.py`

- [ ] **Step 1: Write the failing test** — `tools/test_extract.py`

```python
import json, subprocess, sys, pathlib
REPO = pathlib.Path(__file__).resolve().parent.parent

def test_regions_json_shape():
    subprocess.run([sys.executable, str(REPO/"tools"/"extract_map.py")], check=True)
    data = json.loads((REPO/"apworld"/"ebf4"/"data"/"regions.json").read_text())
    assert "regions" in data and "edges" in data and "map_to_area" in data
    # every map that has a chest must appear in map_to_area
    chests = json.loads((REPO/"apworld"/"ebf4"/"data"/"chests.json").read_text())
    maps = {str(c["map"]) for c in chests}
    assert maps <= set(data["map_to_area"].keys())
    # edges reference known items; requires is a list
    for e in data["edges"]:
        assert isinstance(e["requires"], list)
        assert "from" in e and "to" in e

if __name__ == "__main__":
    test_regions_json_shape(); print("ok")
```

- [ ] **Step 2: Run, expect fail** — `python tools/test_extract.py` → FAIL (no extract_map.py).

- [ ] **Step 3: Implement `extract_map.py`.** Parse `reference/ebf4-decompile/scripts/default_package/MapData.as`:
  - Split `setMap` into per-map `case <n>:` blocks (map id = case number).
  - Per block, collect required items from `initScenes(..., Items.<name>, true)` (5th arg = `Items.X`, 6th = `true` ⇒ blocking) and `initKey(_, Items.<key>)`.
  - Collect adjacency from `door<N>.into = <mapId>` and `Maps.warpData[<n>] = true`/warp targets (best-effort; where a door's target map is literal, add edge current→target).
  - Map→area from the existing `AREA_NAMES` groupings in `data.py` (import the mapping) plus each chest's `area` in `chests.json` (authoritative for chest maps).
  - Emit `{regions:[area names], edges:[{from,to,requires}], map_to_area:{map:area}, map_requires:{map:[items]}}`. `map_requires` = cumulative blocking items on that map (fallback model input).

```python
import json, re, pathlib
REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO/"reference"/"ebf4-decompile"/"scripts"/"default_package"/"MapData.as"
CHESTS = json.loads((REPO/"apworld"/"ebf4"/"data"/"chests.json").read_text())

ITEM = r"Items\.([A-Za-z0-9_]+)"

def main():
    text = SRC.read_text(encoding="utf-8", errors="replace")
    # crude case splitter on the big setMap switch
    blocks = {}
    for m in re.finditer(r"case (\d+):(.*?)(?=case \d+:|default:|\Z)", text, re.S):
        blocks[int(m.group(1))] = m.group(2)
    map_requires, edges = {}, []
    for mid, body in blocks.items():
        reqs = set()
        for mm in re.finditer(r"initScenes?\([^)]*?"+ITEM+r"\s*,\s*true", body):
            reqs.add(mm.group(1))
        for mm in re.finditer(r"initKey\([^,]*,\s*"+ITEM, body):
            reqs.add(mm.group(1))
        map_requires[str(mid)] = sorted(reqs)
        for mm in re.finditer(r'door\d+"?\)?\.into\s*=\s*(\d+)', body):
            edges.append({"from": str(mid), "to": mm.group(1), "requires": sorted(reqs)})
    # area assignment: chest maps are authoritative
    map_to_area = {}
    from importlib import util
    # reuse AREA_NAMES without importing the package (avoid AP deps)
    area_names = _area_names()
    for c in CHESTS:
        map_to_area[str(c["map"])] = area_names.get(c["area"], c["area"])
    out = {"regions": sorted(set(map_to_area.values())), "edges": edges,
           "map_to_area": map_to_area, "map_requires": map_requires}
    (REPO/"apworld"/"ebf4"/"data"/"regions.json").write_text(json.dumps(out, indent=1))
    print(f"regions={len(out['regions'])} edges={len(edges)} maps={len(map_to_area)}")

def _area_names():
    return {"TOWN1":"Greenwood","GRAVEYARD":"Graveyard","ASHWOOD":"Ashwood Forest",
            "CAVERNS":"Crystal Caverns","TOWN2":"Whitefall Town","FACTORY":"The Kitten Kaboodle",
            "JUNGLE":"Lankyroot Jungle","TOWN3":"Redpine Town","TEMPLE":"Temple of Godcat",
            "EXTRA":"Battle Mountain"}

if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run, expect pass** — `python tools/test_extract.py` → `ok`. Manually eyeball `regions.json`: each area should list the expected gating items (Ashwood→axe/copperkey, Caverns→candle, etc.). If adjacency is sparse, that's fine — the fallback model (Task 3) uses `map_requires`.

- [ ] **Step 5: Commit** — `git add tools/extract_map.py tools/test_extract.py apworld/ebf4/data/regions.json && git commit -m "feat(logic): extract EBF4 region graph from MapData.as"`

## Task 2: Region loader

**Files:** Create `apworld/ebf4/regions.py`; Test `tools/test_logic.py` (part 1).

- [ ] **Step 1: Failing test** — assert loader yields area→required-items map and that Greenwood requires nothing (start area).

```python
# tools/test_logic.py
import json, pathlib
REPO = pathlib.Path(__file__).resolve().parent.parent
import sys; sys.path.insert(0, str(REPO/"apworld"))
from ebf4 import regions

def test_area_requirements():
    reqs = regions.area_requirements()   # {area: set(item_names)}
    assert reqs["Greenwood"] == set()
    assert "axe" in reqs["Ashwood Forest"] or "copperkey" in reqs["Ashwood Forest"]

if __name__ == "__main__":
    test_area_requirements(); print("logic part1 ok")
```

- [ ] **Step 2: Run, expect fail.**

- [ ] **Step 3: Implement `regions.py`.** Load `regions.json` via `pkgutil.get_data` (zip-safe). `area_requirements()` = for each area, the union of `map_requires` over that area's maps that lie *beyond* the start area, minus items found earlier — but keep it **conservative**: an area requires the union of blocking items on its maps and on the areas topologically before it (following `map_to_area` order Greenwood→…→Temple). Provide `AREA_ORDER` (the canonical vanilla progression) as a constant so requirements accumulate along it. Greenwood = start = `set()`.

```python
import json, pkgutil
_data = json.loads(pkgutil.get_data(__package__, "data/regions.json").decode("utf-8"))
AREA_ORDER = ["Greenwood","Ashwood Forest","Graveyard","Crystal Caverns","Whitefall Town",
              "The Kitten Kaboodle","Lankyroot Jungle","Redpine Town","Temple of Godcat","Battle Mountain"]

def area_requirements():
    per_area = {a: set() for a in AREA_ORDER}
    for mid, area in _data["map_to_area"].items():
        per_area.setdefault(area, set()).update(_data["map_requires"].get(mid, []))
    # accumulate along the canonical order (conservative: never under-gates)
    acc, out = set(), {}
    for a in AREA_ORDER:
        acc |= per_area.get(a, set())
        out[a] = set(acc)
    out["Greenwood"] = set()
    return out
```

- [ ] **Step 4: Run, expect pass.**
- [ ] **Step 5: Commit** — `git commit -m "feat(logic): region requirement loader"`

## Task 3: World uses regions + tool shuffle

**Files:** Modify `apworld/ebf4/data.py`, `apworld/ebf4/__init__.py`, `apworld/ebf4/options.py`; Test `tools/test_logic.py` (part 2).

- [ ] **Step 1: Failing solver test** — generate-free fill check: build the multiworld twice (`randomize_tools` on/off), assert `state` can reach every region and completion condition is satisfiable.

```python
def test_completable_both_modes():
    from ebf4 import testsupport   # tiny helper that builds a MultiWorld with the world
    for rt in (True, False):
        mw = testsupport.build(randomize_tools=rt, seed=1)
        mw.fill()  # raises FillError if impossible
        assert mw.can_beat_game()
```

  (`testsupport.build` wraps AP's test MultiWorld harness — see AP `test/general`. If the frozen release lacks test modules, run this against the `reference/Archipelago` source checkout instead; document the command.)

- [ ] **Step 2: Run, expect fail.**

- [ ] **Step 3: Implement.**
  - `data.py`: stop excluding gating chests. Add all 455 chests as locations. Add the 11 tools/keys as *items* (`progression`). Add `classification` per item: tools/keys `progression`; gold/consumable bundles `filler`; gear/skills `useful`. Add `progressive_keys` handling (collapse 4 keys → `Progressive Key` ×4). Add `chest_contents` mode (`vanilla` keeps bundle-per-chest; `shuffled` builds one flat item pool of all contents).
  - `__init__.py`: `create_regions` builds one AP `Region` per area, connects them in `AREA_ORDER` with `Entrance.access_rule = lambda state, req=reqs[area]: state.has_all(req, player)` (using `regions.area_requirements()`), attaches each chest location to its area's region. When `randomize_tools` off: remove tools from pool, leave them as vanilla (locations still exist but their item is the vanilla tool placed locally via `local_items`/locked placement), rules trivially satisfied.
  - Goal event as today but gated on the chosen `goal`.

- [ ] **Step 4: Run, expect pass** (against source AP). Also run a real generation: `ArchipelagoGenerate.exe` with `randomize_tools: true`.
- [ ] **Step 5: Commit** — `git commit -m "feat(logic): region-gated world with shuffled tools"`

## Task 4: Options + presets

**Files:** Modify `apworld/ebf4/options.py`; Create `apworld/ebf4/presets.py`; Modify `__init__.py` (apply preset in `generate_early`).

- [ ] **Step 1: Failing test** — `preset: chaos` yields trap_percentage 40, death_link on, goal check_percent, unless explicitly overridden.

```python
def test_preset_chaos():
    from ebf4 import testsupport
    o = testsupport.options(preset="chaos")
    assert o.trap_percentage.value == 40 and o.death_link.value and o.goal.current_key == "check_percent"
def test_explicit_overrides_preset():
    o = testsupport.options(preset="chaos", trap_percentage=5)
    assert o.trap_percentage.value == 5
```

- [ ] **Step 2: Run, expect fail.**

- [ ] **Step 3: Implement.** Add every option from the spec table to `options.py` (`preset`, `goal`, `boss_hunt_count`, `check_percentage`, `randomize_tools`, `randomize_bosses/medals/bestiary/secrets`, `starting_tools`, `chest_contents`, `progressive_keys`, `encounter_rate`, `trap_percentage`, `trap_types`, `difficulty`, `in_game_messages`, `death_link`). `presets.py` maps `order`/`chaos` → dict of defaults; `generate_early` applies preset values only to options the player left at their own default (track via a sentinel or compare to option default). `starting_tools`: push N random tool item names into `self.options.start_inventory` equivalent (`self.multiworld.push_precollected`).

- [ ] **Step 4: Run, expect pass.**
- [ ] **Step 5: Commit** — `git commit -m "feat(options): full option set + order/chaos presets"`

## Task 5: Traps + item classification in pool

**Files:** Create `apworld/ebf4/traps.py`; Modify `data.py`, `__init__.py`.

- [ ] **Step 1: Failing test** — with `trap_percentage: 40` and `trap_types` = {poison}, ~40% of filler items are `Poison Trap` and none are other trap kinds.
- [ ] **Step 2: Run, expect fail.**
- [ ] **Step 3: Implement.** `traps.py` defines 4 traps (`Poison Trap`, `Gold Loss Trap`, `Encounter Trap`, `Stat Down Trap`) with grant `[["trap","<kind>",0]]` and classification `trap`. In `create_items`, replace `trap_percentage`% of `filler` items with traps drawn from enabled `trap_types`.
- [ ] **Step 4: Run, expect pass.**
- [ ] **Step 5: Commit** — `git commit -m "feat(items): traps + filler/useful/progression classification"`

## Task 6: Battle/boss checks + goal (mod + world + client)

**Files:** Modify `gamemod/scripts/Game.as` (endBattle hook), `apworld/ebf4/data.py` (battle locations), `apworld/ebf4/__init__.py` (goal=godcat via battle location), `ebf4_client.py` (handle `battle_` checks).

- [ ] **Step 1: Failing test** — mock-game harness sends `{type:"check","location":"battle_33_0"}` (a godcat map/battle id); assert client forwards LocationChecks and, when it's the goal location, sends CLIENT_GOAL. Extend `tools/test_client.py`.
- [ ] **Step 2: Run, expect fail.**
- [ ] **Step 3: Implement.**
  - `Game.as` `endBattle`: after `Maps.foeData[mapNo][battleNo]=2`, if `win` and this `(mapNo,battleNo)` is managed, `AP_sendCheck("battle_"+mapNo+"_"+battleNo)` (idempotent — foeData already prevents re-fire). Guard in try/catch; suppress nothing (battles have no loot to suppress).
  - `data.py`: add `battle_*` locations. Identify boss/major battles from `Battles.as` named arrays vs. `Maps.foeData` structure; for Phase 1, treat every scripted non-respawnable battle as a `battle_` location (respawnable ones excluded — `foeData==3`). Godcat battle id → `GOAL_BATTLE`.
  - `__init__.py`: `goal=godcat` ⇒ completion condition = the godcat battle location checked (place a locked `Victory`); `boss_hunt` ⇒ N battle items; `check_percent` ⇒ % locations.
  - `ebf4_client.py`: `battle_` ids already flow through `location_keys`; goal detection fires on the goal condition.
- [ ] **Step 4: Verify.** Run `python tools/test_client.py`. Then patch the game (`python tools/patch.py`), live smoke test on File 7: win a scripted battle, confirm `battle_` check in client log.
- [ ] **Step 5: Commit** — `git commit -m "feat(checks): battle/boss locations + godcat goal"`

## Task 7: tkinter client GUI

**Files:** Create `ebf4_client_gui.py`; Modify `ebf4_client.py` (no-args → GUI), `tools/make_dist.py` (bundle `.pyw`).

- [ ] **Step 1: Failing test** — `tools/test_client.py`: importing `ebf4_client_gui` exposes `run_gui(client_factory)`; construct with a fake factory, assert it builds a Tk root without connecting (headless: use `Tk()` in a try/except that skips if no display — on Windows there is one).
- [ ] **Step 2: Run, expect fail.**
- [ ] **Step 3: Implement.** `ebf4_client_gui.py`: a Tk window with Server/Slot/Password entries, Connect/Disconnect button, a scrolledtext log, a "game ●" indicator (green when `game_writer` set), and a "Grant tool ▾" menu invoking the client's `/tool`. It runs the asyncio client loop in a background thread and marshals log lines to the text widget via `root.after`. `ebf4_client.py`: if `len(sys.argv)==1` and Tk import succeeds → `ebf4_client_gui.run_gui(...)`; else console `main()`. Route `self.log` through an injectable sink so GUI captures it.
- [ ] **Step 4: Verify.** `python ebf4_client.py` opens the window; connect to the live test server; confirm log + game indicator. `python tools/make_dist.py` includes `ebf4_client.py`, `ebf4_client_gui.py`, and a `ebf4_client.pyw` shim.
- [ ] **Step 5: Commit** — `git commit -m "feat(client): standalone tkinter GUI"`

## Task 8: Banner overlay for major events + scouts

**Files:** Modify `ebf4_client.py` (emit `msg` frames for events, LocationScouts, `in_game_messages` gate), `gamemod/scripts/Game.as` (already renders `msg`; add highlight style for tool pickups).

- [ ] **Step 1: Failing test** — client with `in_game_messages` on emits a `Sent X to Y` msg when a scouted foreign location is checked, and suppresses all msgs when off. Extend `tools/test_client.py`.
- [ ] **Step 2: Run, expect fail.**
- [ ] **Step 3: Implement.** On Connected: send `LocationScouts` for all locations. Store `locations_info`. On outgoing check of a foreign location → `Sent <item> to <player>` msg. On received tool/key → `Got <name>!` (highlight flag). DeathLink/trap/boss/goal/link-status → msg. Gate all on `in_game_messages` (from slot_data). `Game.as`: `AP_toast(text, highlight)` uses a different banner color when highlight.
- [ ] **Step 4: Verify.** mock-harness test + live: open a chest, see the banner.
- [ ] **Step 5: Commit** — `git commit -m "feat(client): banner overlay for all major events + scouts"`

## Task 9: /tool failsafe + encounter_rate + phase-1 docs/dist

**Files:** Modify `ebf4_client.py` (`/tool`), `gamemod/scripts/Game.as` (encounter_rate apply, tool grant), `ebf4_example.yaml`, `SETUP.md`, `README.md`, `archipelago.json` (→1.2.0), `tools/make_dist.py`.

- [ ] **Step 1–3:** `/tool <name>` sends an `item` frame granting the tool. `encounter_rate` from slot_data → `Game.as` sets encounter frequency at load (`reduced`/`off`). Rewrite `ebf4_example.yaml` casual-first (only `preset` + `goal` uncommented, everything else commented with defaults). Update SETUP (GUI: double-click `ebf4_client.pyw`; casual = pick a preset) and README.
- [ ] **Step 4:** Full regression: `python tools/test_extract.py && python tools/test_logic.py && python tools/test_client.py`; generate a seed; live smoke on File 7 (open chest, win battle, banner shows, goal fires on godcat). Bump `archipelago.json` to `1.2.0`, `make_dist.py`.
- [ ] **Step 5: Commit** — `git commit -m "feat: phase 1 complete — competent EBF4 world (1.2.0)"`

---

# PHASE 2 — EBF4 flavor (v1.3.0 internal milestone)

Medals + bestiary + secret checks, summon/quest items, difficulty/party options.

## Task 10: Medal checks
- `gamemod/scripts/Game.as`: hook `Medals.saveMisc()`/unlock path → `AP_sendCheck("medal_"+name)` for newly-earned medals (track earned set in `EBF4AP.sol`). `data.py`: add `medal_*` locations from `Medals.as`'s ~35 names. Client handles them via `location_keys`. Test: mock check `medal_treasurehunter`. Commit.

## Task 11: Bestiary (first-defeat) checks
- `Game.as`: maintain `AP_state.data.foesKilled` set; in `endBattle` win, for each distinct foe class in `Battle.foes` not already recorded, record + `AP_sendCheck("foe_"+foeId)` (only when `randomize_bestiary`). `data.py`: enumerate foe ids from `Foes.as`. Heaviest hook — new persisted state; guard carefully. Test: mock `foe_<id>`; live: kill a new enemy type. Commit.

## Task 12: Secret/cat checks
- `Game.as`: hook the secret/cat pickup (increments `secretsFound`) → `AP_sendCheck("secret_"+map+"_"+idx)` when `randomize_secrets`. `data.py`: enumerate secrets from MapData. Test + live. Commit.

## Task 13: Summon + quest items, difficulty/party options
- `AP_applyItem` grant kinds for summon unlock + quest flags; `data.py` adds these items; `difficulty` and `starting_party` applied at new-game/load in `Game.as`. Test + live. Commit. Bump 1.3.0, make_dist.

---

# PHASE 3 — Nice-to-have (folds into 2.0.0)

## Task 14: PopTracker pack (optional, data-only)
- Generate a minimal PopTracker pack from `regions.json` + locations (separate `tracker/` dir, zipped by make_dist). No game/client code. Test: pack loads in PopTracker (manual). Commit.

## Task 15: Extra links + plando
- `RingLink`/`EnergyLink` optional tags in client (guarded, off by default); confirm AP-core plando works (document). Commit.

---

# RELEASE 2.0.0

## Task 16: Full regression + version + bundle
- [ ] Run all headless tests green.
- [ ] Generate seeds for `preset: order` and `preset: chaos`; both solve.
- [ ] Live end-to-end on File 7: chest check, battle check + godcat goal, medal, bestiary, secret, a trap, banner overlay, tkinter GUI connect, `/tool` failsafe.
- [ ] Bump `archipelago.json` `world_version` → `2.0.0`; update SETUP/README; `python tools/make_dist.py` → `build/ebf4-ap-2.0.0.zip`.
- [ ] Update memory `ebf4-runtime-architecture.md` with the 2.0.0 architecture.
- [ ] **Commit locally. DO NOT push or tag.** Present `build/ebf4-ap-2.0.0.zip` + a test report to the user for verification. Push + tag `v2.0.0` only after the user confirms.

---

## Self-review notes
- **Spec coverage:** region logic (T1–3), tool safety net `/tool`+`randomize_tools:false` (T3,T9), goal variants (T6), presets (T4), traps+classification (T5), banner events (T8), battle/medal/bestiary/secret checks (T6,T10–12), all control options (T4), summon/quest/difficulty (T13), tkinter client (T7), casual-first docs (T9), tests (T1–8), PopTracker/links/plando (T14–15). All spec sections mapped.
- **Risk:** T1 adjacency parsing may be sparse → the conservative `AREA_ORDER` accumulation in T2/T3 is the real logic backbone (map-level edges are a refinement, not required for correctness). T11 bestiary is the riskiest hook; it is optional and isolated.
- **Type consistency:** `AP_sendCheck(location)`, `area_requirements()->{area:set}`, grant kinds `poison/goldloss/encounter/statdown/trap`, location key families `chest_/battle_/medal_/foe_/secret_` used consistently.
