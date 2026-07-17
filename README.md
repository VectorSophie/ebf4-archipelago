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

## Wire protocol (v1)

4-byte big-endian length prefix + UTF-8 JSON, over `127.0.0.1:26510`.

| direction | message |
|---|---|
| game → bridge | `{"type":"hello","game":"EBF4","protocol":1,"itemIndex":N}` |
| game → bridge | `{"type":"check","location":"chest_<map>_<idx>"}` |
| game → bridge | `{"type":"pong"}` |
| bridge → game | `{"type":"item","index":N,"item":"money","amount":M}` |
| bridge → game | `{"type":"ping"}` |

The game applies items only in map mode, stores the next expected index in a SharedObject
(`EBF4AP.sol`), and skips any index it has already applied.
