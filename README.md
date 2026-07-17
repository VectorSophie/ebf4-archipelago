# EBF4 Archipelago

Experimental [Archipelago](https://archipelago.gg) multiworld support for the Steam version
of Epic Battle Fantasy 4. Working vertical slice: chest openings become location checks,
items arrive over a local TCP bridge, delivery is idempotent across restarts.

**No game assets are distributed.** The patcher modifies your own legally installed copy
and keeps a backup.

## Layout

- `docs/RESEARCH.md` — architecture research, hook points, risks (start here)
- `gamemod/scripts/` — the two modified ActionScript classes imported into the SWF
  (`Game.as` carries all AP code as `AP_*` statics; `Chest.as` has the check hook)
- `gamemod/vanilla/` — unmodified exports of the same classes, for diffing
- `bridge/bridge.py` — local test bridge (not yet a real AP client)
- `tools/patch.py` — patch / `--restore` the installed game
- `reference/`, `tools-dl/`, `build/` — gitignored: cloned reference repos, FFDec, scratch

## Requirements

- EBF4 on Steam, v3.0.6 (SWF sha256 `baea1855...`, verified by the patcher)
- Java 8+, Python 3.10+
- [FFDec](https://github.com/jindrapetrik/jpexs-decompiler) ≥ 24 at `tools-dl/ffdec/ffdec-cli.jar`
  (or pass `--ffdec-jar`)

## Quick start

```
python tools/patch.py            # patch (creates Epic Battle Fantasy 4.vanilla.swf backup)
python bridge/bridge.py --auto-item
# launch EBF4 via Steam, load a save, open a chest
python tools/patch.py --restore  # back to vanilla
```

## Playing a seed (demo world: the 20 Greenwood chests)

```
# one-time: install the world into your Archipelago checkout
cp -r apworld/ebf4 reference/Archipelago/worlds/

cd reference/Archipelago
python Generate.py                      # with a Players/*.yaml for "Epic Battle Fantasy 4"
python MultiServer.py output/AP_*.zip
cd ../..
python bridge/ap_client.py --connect localhost:38281 --name <slot>
# launch the patched game and play; Greenwood chests are checks
```

Opening a managed chest suppresses its vanilla loot and sends the check; received
multiworld items pop the normal "Found treasure!" box. Item delivery is idempotent and
scoped per seed+slot (`EBF4AP.sol` stores `session` + `itemIndex`).

## Wire protocol (v2)

4-byte big-endian length prefix + UTF-8 JSON, over `127.0.0.1:26510`.

| direction | message |
|---|---|
| game → client | `{"type":"hello","game":"EBF4","protocol":2,"itemIndex":N,"session":S}` |
| game → client | `{"type":"check","location":"chest_<map>_<idx>"}` |
| game → client | `{"type":"pong"}` |
| client → game | `{"type":"session","session":"<seed>:<slot>","locations":["chest_9_0",...]}` |
| client → game | `{"type":"item","index":N,"name":"...","grant":[["i","turnip",3],["e","cloverpin",1],["s","rain",0],["money","",100]]}` |
| client → game | `{"type":"ping"}` |

Handshake: game says hello → client sends session config → game resets its item index if
the session changed and re-hellos → client replays items from the game's index. The game
applies items only in map mode and skips indices it has already applied.
