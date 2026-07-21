# EBF4 Archipelago

[Archipelago](https://archipelago.gg) multiworld support for the Steam version of Epic
Battle Fantasy 4. Location checks span **treasure chests, boss battles, medals, and the
bestiary** (first defeat of each foe); doing any of them sends a check and you receive
other players' items in return. The traversal **tools** (axe, candle, hammer, boots,
ladder) are shuffled into the multiworld with region logic that keeps every seed beatable;
the consumable **keys** stay vanilla so key-gated content is always reachable in order.
Configurable goal (beat Godcat / hunt N bosses / check a %), order/chaos presets, traps,
difficulty, DeathLink, and an on-screen banner for every major event.

**No game assets are distributed.** The patcher modifies your own legally installed copy
and keeps a backup.

## Just want to play? → [SETUP.md](SETUP.md)

Build the player bundle to hand to a friend:

```
python tools/make_dist.py        # -> build/ebf4-ap-<version>.zip
```

That zip contains `ebf4.apworld`, the patcher, the mod scripts, `SETUP.md`, and an
example YAML — everything a player needs on top of an official Archipelago release.

## Layout

- `SETUP.md` — player-facing setup guide
- `apworld/ebf4/` — the Archipelago world: locations/items (`data.py`), region logic
  (`regions.py`), options (`options.py`), presets (`presets.py`), generated data
  (`data/{chests,regions,medals,foes}.json`)
- `ebf4_client.py` — standalone client bridging the patched game to an AP server (run
  with your own Python; only needs `pip install websockets`). No args → tkinter GUI
  (`ebf4_client_gui.py`); args → console. `/tool <name>` grants a tool as a failsafe.
- `docs/RESEARCH.md` — architecture research, hook points, risks
- `gamemod/scripts/` — the modified ActionScript classes imported into the SWF
  (`Game.as` carries the AP layer as `AP_*` statics; `Chest.as`/`MapPlayer.as`/`Battle.as`/
  `Medals.as` add the chest, battle, foe-spawn, medal, loot-suppression, and DeathLink hooks)
- `gamemod/vanilla/` — unmodified exports of the same classes, for diffing
- `tools/patch.py` — patch / `--restore` the installed game (auto-downloads FFDec)
- `tools/extract_{chests,map,medals,foes}.py` — regenerate the `data/*.json` tables from
  the decompiled game source
- `tools/make_dist.py` — assemble the player bundle
- `bridge/bridge.py` — minimal standalone test bridge (dev only)
- `reference/`, `tools-dl/`, `build/` — gitignored: cloned reference repos, FFDec, scratch

## Requirements

- EBF4 on Steam, v3.0.6 (SWF sha256 `baea1855...`, verified by the patcher)
- Java 8+, Python 3.10+ (the patcher auto-downloads FFDec)
- Archipelago 0.6.0+ (official release) to host/play

## Dev quick start

```
python tools/patch.py                         # patch (backs up the vanilla SWF)
cp -r apworld/ebf4 reference/Archipelago/worlds/   # or install the .apworld in custom_worlds
cd reference/Archipelago
python Generate.py                            # with a Players/*.yaml for "Epic Battle Fantasy 4"
python MultiServer.py output/AP_*.zip
python ebf4_client.py localhost:38281 Player1  # then launch the patched game, open chests
python tools/patch.py --restore               # back to vanilla
```

Opening a managed chest suppresses its vanilla loot and sends the check; received
multiworld items pop the normal "Found treasure!" box. Item delivery is idempotent and
scoped per seed+slot (`EBF4AP.sol` stores `session`, `itemIndex`, and buffered `checks`).

## Quality-of-life features

- **On-screen toasts** — an overlay banner (added to `stage`, above the game's frame) shows
  "Received X from Y", "Sent X to Z", goal completion, and DeathLink messages.
- **Offline check buffer** — checks made while the client is down are stored in `EBF4AP.sol`
  and re-sent on reconnect.
- **DeathLink** (`--death-link`) — a party wipe (`Battle.gameover`) broadcasts a death; an
  incoming death shows a toast and defeats your party via the game's own game-over path.
  A suppress flag prevents a received death from echoing back out.
- **Goal** — configurable (beat Godcat / hunt N bosses / check a %); the client
  evaluates it from checked locations and sends `StatusUpdate: CLIENT_GOAL`.

## Wire protocol (v2)

4-byte big-endian length prefix + UTF-8 JSON, over `127.0.0.1:26510`.

| direction | message |
|---|---|
| game → client | `{"type":"hello","game":"EBF4","protocol":2,"itemIndex":N,"session":S}` |
| game → client | `{"type":"check","location":"<key>"}` — key is `chest_<map>_<idx>`, `battle_<map>_<idx>`, `medal_<id>`, or `foe_<id>` |
| game → client | `{"type":"death"}` (party wiped) |
| game → client | `{"type":"pong"}` |
| client → game | `{"type":"session","session":"<seed>:<slot>","locations":[...],"difficulty":"hard"}` |
| client → game | `{"type":"item","index":N,"name":"...","text":"...","grant":[["i","turnip",3],["e","cloverpin",1],["s","rain",0],["money","",100],["trap","goldloss",0]]}` |
| client → game | `{"type":"grant","grant":[...]}` — out-of-band `/tool` failsafe, applied once bypassing item-index dedup |
| client → game | `{"type":"msg","text":"..."}` (toast) |
| client → game | `{"type":"deathlink","source":"..."}` |
| client → game | `{"type":"ping"}` |

Grant kinds: `i`/`e`/`s` = Items/Equips/Spells (`.quantity`/`.owned`), `money`, and
`trap` (`goldloss` deducts gold; `poison`/`statdown`/`encounter` set a self-clearing
foe-difficulty flag for the next battle). `difficulty` in `session` sets `Options.difficulty`.

Handshake: game says hello → client sends session config → game resets its item index if
the session changed and re-hellos → client replays items from the game's index. The game
applies items only in map mode and skips indices it has already applied.
