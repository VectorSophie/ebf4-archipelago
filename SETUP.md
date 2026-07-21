# EBF4 Archipelago — Player Setup

Play the Steam version of **Epic Battle Fantasy 4** in an Archipelago multiworld.
This patches *your own* legally-owned copy of the game and is fully reversible.

## What you need

- **Epic Battle Fantasy 4 on Steam** (this targets Steam build `14083646`, v3.0.6).
- **Java 8+** on your PATH — <https://adoptium.net> (for the patch step).
- **Python 3.10+** — <https://python.org> (for the patch step and the client).
- **Archipelago 0.6.0+** — <https://github.com/ArchipelagoMW/Archipelago/releases>
  (the normal Windows installer/release).
- One Python package for the client: `pip install websockets`.

You do **not** need the Archipelago source or any dev tools. The mod files here are
script-only — no game art, audio, or SWF is distributed.

## 1. Install the world

Copy `ebf4.apworld` into your Archipelago install's **`custom_worlds`** folder
(create it next to `ArchipelagoLauncher.exe` if it isn't there). That's all the
generator needs to know the game.

> The client is the separate `ebf4_client.py` script in this folder (see step 4),
> **not** a Launcher button. It runs as its own process so it can't collide with
> the Archipelago Launcher's own window.

## 2. Patch your game

From this folder:

```
python tools/patch.py
```

It finds your EBF4 install automatically (across Steam libraries), downloads the
SWF tool on first run, verifies your game is the expected version, makes a backup,
and patches it. To go back to vanilla anytime:

```
python tools/patch.py --restore
```

> Steam Cloud note: your saves (`EBF4_*.meow`) are untouched. The Archipelago item
> counter is stored separately (`EBF4AP.sol`) and is scoped per seed, so it can't
> corrupt a normal save.

## 3. Get a seed

Someone in your group generates the multiworld (any Archipelago host). Each EBF4
player provides a YAML like `ebf4_example.yaml` (in this folder) with their name and
options. The host runs the generator and starts a server (or uploads to
<https://archipelago.gg>). You'll get a **server address, port, and your slot name**.

Options:
- `chests_required` — how many treasure bundles you must collect to win (lower =
  shorter game; default = all 430).
- `death_link` — if on, dying links deaths with other DeathLink players.

## 4. Play

1. Start the client from this folder (once, `pip install websockets` first):

   ```
   python ebf4_client.py <server:port> <your slot name>
   ```

   e.g. `python ebf4_client.py localhost:38281 Player1`, or for a hosted room
   `python ebf4_client.py archipelago.gg:12345 Player1 mypassword`. It prints
   `session ...: N locations` once connected and then waits for the game.
2. Start EBF4 normally through Steam and load (or start) a save.
3. The client and game connect automatically over `127.0.0.1:26510`.
4. Open chests to send checks; received items appear as the normal "Found treasure!"
   popup, with a banner at the top of the screen telling you what arrived.

> **Start the client _before_ you open chests.** Chests you open while no client is
> connected are buffered under the game's current session; switching to a different
> seed can drop that buffer. For a clean run, use a **fresh save file** for each seed
> — and keep your real save on a different file so it's never touched.

Chests that hold the game's own progression tools (keys, axe, candle, boots, hammer)
are left vanilla so you can never soft-lock — every other chest is a check.

## Troubleshooting

- **"Could not find Epic Battle Fantasy 4.swf"** — pass `--game-dir "…"` pointing at
  your install folder (the one containing `EBF4.exe`).
- **"…is not the known vanilla build"** — verify the game files in Steam (Properties →
  Installed Files → Verify integrity), then re-run the patch.
- **Client shows no game connection** — make sure the patched game is running and you
  are in a save file (the game connects a few seconds after `Game.init`, i.e. after the
  title screen). It retries automatically.
- **Java not found** — install Temurin/OpenJDK and reopen your terminal.
