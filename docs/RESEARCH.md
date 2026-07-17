# EBF4 Archipelago — Research Notes

Date: 2026-07-17. All findings verified against the installed Steam copy unless noted.

## 1. EBF4 Steam runtime and file structure

- Steam buildid **14083646**, in-game version **3.0.6** (title screen).
- Captive-runtime **HARMAN Adobe AIR 50.2** app (`application.xml` namespace `air/50.2`):
  - `EBF4.exe` — generic AIR launcher (sha256 `0714ebc4...c2a1a5`)
  - `Epic Battle Fantasy 4.swf` — the entire game, 164 MB, uncompressed (FWS).
    **Vanilla sha256 `baea1855d42cf5cf826e92059b5f480a6b23389ce40f1f04cbb0ac2f6feea957`**
  - `META-INF/AIR/extensions/com.amanitadesign.steam.FRESteamWorks` — Steamworks ANE
  - Saves: `EBF4_file1..7.meow`, `EBF4_autosave.meow`, `EBF4_medals.meow`, `EBF4_options.meow`
    (base64-encoded JSON) **in the game directory itself**; Steam autocloud syncs `*.meow`.
  - `errorLog.txt` — written by the game, but **only flushed on uncaught errors**
    (`AppFeatures.log`), not by `traceLog`. Don't rely on it for routine AP logging.
- `supportedProfiles` includes `extendedDesktop`; the game itself uses `NativeProcess`
  (launches `QRes.exe` for resolution changes) — full AIR desktop API surface is available.
- AIR does **not** verify the SWF signature at launch: a modified SWF runs fine (verified).
- **Key discovery**: the old EBF4 wrapper architecture (LocalConnection `EBF4toWrapper`,
  still present in `Main.as`) is dead code. The Steam build has an in-SWF class
  **`AppFeatures`** that does file I/O, window management, Steamworks achievements, and
  error logging directly via AIR APIs. There is no second process and no wrapper SWF.
- SharedObjects (.sol) persist under
  `%APPDATA%\EpicBattleFantasy4\Local Store\#SharedObjects\Epic%20Battle%20Fantasy%204.swf\`.

## 2. EBF5 Archipelago project (NitroTears/EBF5-AP-ScriptMods)

- Early-stage. Reusable ideas:
  - JPEXS/FFDec script import workflow; only modified scripts kept in repo (`import/scripts/`),
    full script export kept alongside for compiler context (`import/all_scripts/`).
  - `APSocket extends flash.net.Socket`: **4-byte big-endian length prefix + UTF-8 JSON**
    framing over localhost TCP. Confirmed comment: sockets "just work" under AIR.
  - xdelta patch distribution for asset-level changes (scripts alone don't need it).
  - They use a fork of FFDec (kijetesantakalu912345) because **new-class import is GUI-only**.
- Their `ItemHandler` (received-item index, idempotent apply) is a stub — design intent only.
- We reuse their wire framing so one bridge could eventually serve both games.

## 3. EBF4 decompiled code (reuser73/ebf4-decompile + own exports)

The decomp repo is close to but not identical to the Steam SWF (Steam build replaced
LocalConnection plumbing with `AppFeatures`). Always export from the real SWF before editing.
Key classes (all in the default package, one big timeline SWF):

- `Game` — static hub. `Game.init()` runs from `Main.initMore()` (main timeline frame 2,
  reached after the preloader "Play/language" screen). `Game.mainLoop` runs every frame;
  `Game.timer` every second. `Game.endBattle()` has win/loss info → future boss checks.
- `Chest` — chest MovieClip. Identity = `(MapData.mapNo, int(name.substring(5)))`.
  `frame4` runs exactly once per opening; state persisted in `Maps.chestData` (array
  `[mapNo][chestIdx]`, 2 = opened) inside normal saves.
- `MapData.setMap` — per-map `objectData` defines chest contents literally, e.g.
  `{"mc":"chest0","type":CHEST,"data":[Equips.cloverpin,1,Items.turnip,3]}` — this is the
  future item-randomization point.
- `MapPlayer.interact()` → `MapMenu.showTreasure(data)` — grants loot via
  `item.quantity += n` / equips. `SaveData.money` is gold; `Constants.STARTING_MONEY = 300`.
- `Events` — 16 static boss/door flags (`OAK_DEFEATED` etc.) → future event checks.
- `SaveData.saveGame/loadGame` — JSON → base64 → `AppFeatures.saveToMeow`. `mapData[6]`
  is chestData. Adding AP fields to the save JSON is possible but not needed yet.
- `Debug.SteamVersion = true` in the Steam SWF.
- `FRESteamWorks` classes are **not** in the SWF ABC (they live in the ANE), so classes that
  import them (`AppFeatures`) can't be recompiled by FFDec — don't hook there.

## 4. Archipelago patterns (precedent)

- Games that can't speak the full AP websocket protocol use a **bridge client**: a Python
  client (subclass of `CommonClient`) speaks AP to the server and a dumb local protocol to
  the game (examples: many console/emulator worlds, EBF5 project). We follow that shape.
- Received items must be applied by **index**: the server resends the full item list on
  connect; the client applies only items with index >= its stored next-index. Checks are
  idempotent server-side (resending a collected location is harmless).

## 5. Communication architecture (decided for the slice)

- **In-game**: `flash.net.Socket` client → `127.0.0.1:26510` (26510 ≈ Steam appid 265610).
  Verified working under the Steam AIR runtime with zero security prompts.
  Wire format: 4-byte BE length + UTF-8 JSON (EBF5-compatible).
- **Outside**: `bridge/bridge.py` (asyncio TCP server). Today a test harness; next step is
  embedding it in an Archipelago `CommonClient`.
- Alternatives considered: LocalConnection wrapper (dead code, rejected), NativeProcess
  spawning the client (possible, adds lifecycle pain), file polling (slow, rejected).

## 6. Hook points used

| Purpose | Hook | Why |
|---|---|---|
| init + connect | `Game.init()` | runs once at startup, tiny dependency-light class |
| item queue pump | `Game.mainLoop()` | every frame, main thread; items applied only when `SaveData.inGame && mode == MAP` |
| reconnect | `Game.timer()` | 1 Hz, retry every 15 s |
| location check | `Chest.frame4` | fires once per chest opening, has map+chest identity |

All hooks are wrapped in try/catch so vanilla behavior survives any AP failure, and the
game plays completely normally when no bridge is listening.

## 7. Save-state and duplicate-delivery risks

- Received-item index is stored in a **SharedObject** (`EBF4AP.sol`), not in the save file.
  Verified: applied exactly once, survives restart, duplicate index skipped.
- **Known desync risk (accepted for the slice)**: reloading an older save keeps the global
  itemIndex, so items delivered after that save's timestamp are lost from inventory but
  still counted as delivered. Real fix later: store index inside the save JSON
  (`SaveData.saveGame`) per-slot, or make items non-inventory (unlocks/flags).
- Chest checks can't duplicate in one playthrough (chestData persists in saves); an
  interrupted chest animation (`chestData == 1`) can re-fire after reload, but AP servers
  ignore duplicate location checks — harmless.

## 8. Legal / distribution constraints

- Never distribute the SWF or assets. The patcher (`tools/patch.py`) modifies the user's
  own legally installed copy, verifies the vanilla sha256 first, and keeps a
  `*.vanilla.swf` backup for one-command restore.
- The repo contains decompiled-derived sources for the two modified classes only
  (same practice as the public EBF5 AP repo; Kupo Games publicly endorses modding and
  decompilation of EBF games — see kupogames.com "EBF Modding" post). No art/audio/binary
  assets are committed.

## 9. Remaining unknowns / next experiments

- FFDec CLI **cannot add new classes** (GUI-only, even in the EBF5 fork) — current mod code
  is embedded in `Game.as`. Revisit: either script the GUI import once and diff-verify, or
  patch the ABC tag directly, if code size in Game.as becomes unmanageable.
- errorLog-based in-game logging is invisible until an error flushes it — consider having
  the bridge be the log sink (game already sends everything relevant).
- `Game.init()` fires only after the player clicks through the preloader — acceptable.
- Item *types* beyond money (inventory items, equips, spells) — grant paths identified
  (`Items.x.quantity`, `Equips`, `Spells.learn?`) but untested.
- Boss/event checks (`Events` flags, `Game.endBattle`) — untested.
- Seed logic / AP world implementation (`worlds/ebf4` in the AP repo) — not started; needs
  location/item tables extracted from `MapData` (scriptable from the decompiled source).

## 10. Vertical slice — executed 2026-07-17, all green

1. `python tools/patch.py` — verified vanilla hash, backed up, imported mod scripts. ✅
2. Launched `EBF4.exe` (Steam copy, normal runtime). ✅
3. Game connected to `bridge.py`; sent `hello` with persisted itemIndex. ✅
4. Opened a real chest (map 27, chest 0) → bridge logged `CHECK chest_27_0`. ✅
5. Bridge sent test item → +100 gold applied in-game (300→400 on first run). ✅
6. Full restart: game reported itemIndex=1, new item applied (500 total),
   deliberately re-sent index 0 was **skipped**. ✅
7. State persisted in `EBF4AP.sol` (verified bytes) and save File 7. ✅

Reproduce: `python tools/patch.py` → `python bridge/bridge.py --auto-item` → launch game →
pick language → load/start a save → open any chest. Restore: `python tools/patch.py --restore`.
