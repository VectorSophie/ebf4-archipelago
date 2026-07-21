#!/usr/bin/env python3
"""EBF4 Archipelago console client.

Bridges a patched Epic Battle Fantasy 4 (JSON frames over 127.0.0.1:26510) to an
Archipelago server. No GUI, no Archipelago Launcher needed -- runs on plain
Python so it works the same on any machine.

    python ebf4_client.py <host:port> <slot name> [password]

Only third-party dependency: websockets  (pip install websockets)

Why this exists instead of a Launcher component: the frozen Archipelago release
runs a world's client `func` inside the Launcher's own process, and Kivy allows
only one GUI app per process, so an apworld-shipped GUI client collides with the
Launcher. A standalone process sidesteps that entirely.
"""
import argparse
import asyncio
import json
import struct
import time
import uuid

CLIENT_STATUS_GOAL = 30
GAME = "Epic Battle Fantasy 4"
DEFAULT_GAME_PORT = 26510


def grant_label(grant):
    """Human label for a grant list like [["i","turnip",3],["money","",100]]."""
    parts = []
    for g in grant:
        if not g:
            continue
        if g[0] == "money":
            parts.append(f"{g[2]} gold")
        else:
            name, qty = g[1], (g[2] if len(g) > 2 else 0)
            parts.append(f"{name} x{qty}" if qty and qty > 1 else str(name))
    return ", ".join(parts) or "an item"


class Client:
    def __init__(self, host, slot, password, game_port):
        self.host = host
        self.slot = slot
        self.password = password
        self.game_port = game_port

        self.ws = None
        self.seed_name = None
        self.slot_num = None
        self.players = {}                 # slot number -> display name
        self.location_keys = {}           # "chest_x_y" -> AP location id
        self.item_grants = {}             # AP item id -> grant list
        self.goal_count = 0
        self.death_link = False
        self.goal_sent = False

        self.checked = set()              # AP location ids we've sent
        self.items_received = []          # list of (item_id, finder_slot)

        self.session = None               # "seed:slot", scopes the game item index
        self.game_writer = None
        self.game_next_index = None       # next item index the game wants

    def log(self, msg):
        print(f"[EBF4] {msg}", flush=True)

    # ---- Archipelago server ----

    async def send(self, *cmds):
        await self.ws.send(json.dumps(list(cmds)))

    async def connect_ws(self):
        import websockets
        errors = []
        for scheme in ("wss", "ws"):
            try:
                self.ws = await websockets.connect(f"{scheme}://{self.host}",
                                                   max_size=None, open_timeout=10)
                self.log(f"connected to {scheme}://{self.host}")
                return
            except Exception as e:  # try the other scheme
                errors.append(f"{scheme}: {e}")
        raise SystemExit("Could not reach the server:\n  " + "\n  ".join(errors))

    async def server_loop(self):
        await self.connect_ws()
        async for raw in self.ws:
            for cmd in json.loads(raw):
                await self.on_cmd(cmd)
        self.log("server connection closed")

    async def on_cmd(self, args):
        cmd = args.get("cmd")
        if cmd == "RoomInfo":
            self.seed_name = args.get("seed_name")
            await self.send({
                "cmd": "Connect", "game": GAME, "name": self.slot,
                "password": self.password, "uuid": str(uuid.getnode()),
                "version": {"major": 0, "minor": 6, "build": 0, "class": "Version"},
                "items_handling": 0b111, "tags": ["AP"], "slot_data": True,
            })
        elif cmd == "ConnectionRefused":
            raise SystemExit("Connection refused: "
                             + ", ".join(args.get("errors", ["unknown"]))
                             + "\nCheck the slot name and that the seed is for EBF4.")
        elif cmd == "Connected":
            self.slot_num = args.get("slot")
            for p in args.get("players", []):
                self.players[p["slot"]] = p.get("alias") or p.get("name")
            for loc in args.get("checked_locations", []):
                self.checked.add(loc)
            sd = args.get("slot_data") or {}
            self.location_keys = sd.get("location_keys", {})
            self.item_grants = {int(k): v for k, v in sd.get("item_grants", {}).items()}
            self.goal_count = int(sd.get("goal_count", len(self.item_grants)))
            self.death_link = bool(sd.get("death_link"))
            self.session = f"{self.seed_name}:{self.slot_num}"
            self.log(f"session {self.session}: {len(self.location_keys)} locations, "
                     f"goal {self.goal_count}, deathlink {self.death_link}")
            await self.game_send_config()
        elif cmd == "ReceivedItems":
            base = args.get("index", 0)
            if base == 0:
                self.items_received = []
            for it in args.get("items", []):
                self.items_received.append((it["item"], it["player"]))
            await self.game_sync_items()
            await self.check_goal()
        elif cmd == "RoomUpdate":
            for p in args.get("players", []):
                self.players[p["slot"]] = p.get("alias") or p.get("name")
            for loc in args.get("checked_locations", []):
                self.checked.add(loc)
        elif cmd == "Bounced":
            if "DeathLink" in (args.get("tags") or []):
                d = args.get("data") or {}
                src = d.get("source", "someone")
                if src != self.slot:
                    await self.game_send({"type": "deathlink", "source": src})
        elif cmd == "PrintJSON":
            pass  # not surfaced; the game shows its own popups

    async def check_goal(self):
        if self.goal_sent or not self.goal_count:
            return
        if len({i for i, _ in self.items_received}) >= self.goal_count:
            self.goal_sent = True
            self.log("goal complete!")
            await self.send({"cmd": "StatusUpdate", "status": CLIENT_STATUS_GOAL})
            await self.game_send({"type": "msg", "text": "GOAL! You win!"})

    # ---- game socket ----

    async def game_send(self, obj):
        w = self.game_writer
        if not w:
            return
        try:
            data = json.dumps(obj).encode("utf-8")
            w.write(struct.pack(">I", len(data)) + data)
            await w.drain()
        except Exception as e:
            self.log(f"send to game failed: {e}")

    async def game_send_config(self):
        if self.session:
            await self.game_send({"type": "session", "session": self.session,
                                  "locations": list(self.location_keys)})

    async def game_sync_items(self):
        if self.game_next_index is None:
            return
        while self.game_next_index < len(self.items_received):
            idx = self.game_next_index
            item_id, finder = self.items_received[idx]
            grant = self.item_grants.get(item_id, [])
            name = grant_label(grant)
            sender = self.players.get(finder, "the server")
            text = f"Received {name} from {sender}" if finder != self.slot_num else None
            await self.game_send({"type": "item", "index": idx, "name": name,
                                  "text": text, "grant": grant})
            self.log(f"sent item {idx}: {name}")
            self.game_next_index += 1

    async def handle_game(self, reader, writer):
        self.log("game connected")
        self.game_writer = writer
        try:
            while True:
                header = await reader.readexactly(4)
                (length,) = struct.unpack(">I", header)
                msg = json.loads((await reader.readexactly(length)).decode("utf-8"))
                await self.handle_game_msg(msg)
        except (asyncio.IncompleteReadError, ConnectionResetError):
            self.log("game disconnected")
        finally:
            if self.game_writer is writer:
                self.game_writer = None
                self.game_next_index = None

    async def handle_game_msg(self, msg):
        t = msg.get("type")
        if t == "hello":
            await self.game_send_config()
            if self.session and msg.get("session", "") == self.session:
                self.game_next_index = int(msg.get("itemIndex", 0))
                self.log(f"game in session, next item index {self.game_next_index}")
                await self.game_sync_items()
                await self.check_goal()
        elif t == "check":
            loc_id = self.location_keys.get(msg.get("location"))
            if loc_id is not None and loc_id not in self.checked:
                self.checked.add(loc_id)
                await self.send({"cmd": "LocationChecks", "locations": [loc_id]})
                self.log(f"check: {msg.get('location')} -> {loc_id}")
        elif t == "death":
            if self.death_link:
                await self.send({"cmd": "Bounce", "tags": ["DeathLink"], "data": {
                    "time": time.time(), "source": self.slot,
                    "cause": f"{self.slot} was defeated"}})

    async def run(self):
        server = await asyncio.start_server(self.handle_game, "127.0.0.1", self.game_port)
        self.log(f"waiting for the game on 127.0.0.1:{self.game_port}")
        async with server:
            await self.server_loop()


def main():
    ap = argparse.ArgumentParser(description="EBF4 Archipelago console client")
    ap.add_argument("server", help="server host:port, e.g. localhost:38281")
    ap.add_argument("slot", help="your slot (player) name")
    ap.add_argument("password", nargs="?", default="", help="server password if any")
    ap.add_argument("--game-port", type=int, default=DEFAULT_GAME_PORT)
    args = ap.parse_args()

    client = Client(args.server, args.slot, args.password, args.game_port)
    try:
        asyncio.run(client.run())
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
