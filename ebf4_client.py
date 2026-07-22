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
import sys
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
        elif g[0] == "party":
            parts.append(str(g[1]).capitalize())
        elif g[0] == "trap":
            parts.append(f"{g[1]} trap")
        else:
            name, qty = g[1], (g[2] if len(g) > 2 else 0)
            parts.append(f"{name} x{qty}" if qty and qty > 1 else str(name))
    return ", ".join(parts) or "an item"


class Client:
    def __init__(self, host, slot, password, game_port, log_sink=None):
        self.host = host
        self.slot = slot
        self.password = password
        self.game_port = game_port
        self._log_sink = log_sink

        self.ws = None
        self.seed_name = None
        self.slot_num = None
        self.players = {}                 # slot number -> display name
        self.location_keys = {}           # "chest_x_y" -> AP location id
        self.item_grants = {}             # AP item id -> grant list
        self.death_link = False
        self.in_game_messages = True
        self.goal = "godcat"
        self.goal_location_key = ""
        self.boss_hunt_count = 10
        self.check_percentage = 100
        self.total_locations = 0
        self.difficulty = ""
        self.party_shuffle = False
        self.goal_sent = False

        self.locations_info = {}          # loc id -> (item id, finder/receiver slot)
        self.item_names = {}              # game -> {item id -> name}
        self.player_game = {}             # slot -> game name
        self.tool_names = {"Axe", "Candle", "Hammer", "Leafy Boots",
                           "Step Ladder", "Thermal Boots", "Winged Boots"}

        self.checked = set()              # AP location ids we've sent
        self.items_received = []          # list of (item_id, finder_slot)

        self.session = None               # "seed:slot", scopes the game item index
        self.game_writer = None
        self.game_next_index = None       # next item index the game wants

    def log(self, msg):
        if self._log_sink:
            self._log_sink(str(msg))
        else:
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
            self.death_link = bool(sd.get("death_link"))
            self.in_game_messages = bool(sd.get("in_game_messages", True))
            # goal config
            self.goal = sd.get("goal", "godcat")
            self.goal_location_key = sd.get("goal_location", "")
            self.boss_hunt_count = int(sd.get("boss_hunt_count", 10))
            self.check_percentage = int(sd.get("check_percentage", 100))
            self.total_locations = int(sd.get("total_locations", len(self.location_keys)))
            self.difficulty = sd.get("difficulty", "")
            self.party_shuffle = bool(sd.get("party_shuffle"))
            for slot, info in (args.get("slot_info") or {}).items():
                self.player_game[int(slot)] = info.get("game")
            self.session = f"{self.seed_name}:{self.slot_num}"
            self.log(f"session {self.session}: {len(self.location_keys)} locations, "
                     f"goal {self.goal}, deathlink {self.death_link}")
            await self.game_send_config()
            # learn item names (for "Sent X to Y") and what each location holds
            await self.send({"cmd": "GetDataPackage"})
            if self.location_keys:
                await self.send({"cmd": "LocationScouts",
                                 "locations": list(self.location_keys.values()),
                                 "create_as_hint": 0})
        elif cmd == "ReceivedItems":
            base = args.get("index", 0)
            if base == 0:
                self.items_received = []
            for it in args.get("items", []):
                self.items_received.append((it["item"], it["player"]))
            await self.game_sync_items()
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
        elif cmd == "DataPackage":
            for game, gd in (args.get("data") or {}).get("games", {}).items():
                self.item_names[game] = {v: k for k, v in
                                         (gd.get("item_name_to_id") or {}).items()}
        elif cmd == "LocationInfo":
            for it in args.get("locations", []):
                self.locations_info[it["location"]] = (it["item"], it["player"])
        elif cmd == "PrintJSON":
            pass  # not surfaced; the game shows its own popups

    def item_name(self, item_id, player):
        game = self.player_game.get(player, "")
        return self.item_names.get(game, {}).get(item_id, "an item")

    async def banner(self, text):
        if self.in_game_messages:
            await self.game_send({"type": "msg", "text": text})

    async def eval_goal(self):
        """Check the win condition against locations checked so far."""
        if self.goal_sent:
            return
        done = False
        if self.goal == "godcat":
            goal_id = self.location_keys.get(self.goal_location_key)
            done = goal_id is not None and goal_id in self.checked
        elif self.goal == "boss_hunt":
            battle_ids = {v for k, v in self.location_keys.items()
                          if k.startswith("battle_")}
            done = len(self.checked & battle_ids) >= self.boss_hunt_count
        elif self.goal == "check_percent":
            need = self.total_locations * self.check_percentage / 100
            done = len(self.checked) >= need
        if done:
            self.goal_sent = True
            self.log("goal complete!")
            await self.send({"cmd": "StatusUpdate", "status": CLIENT_STATUS_GOAL})
            await self.banner("GOAL! You win!")

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

    def tool_grant(self, name):
        """Grant list for one of our own tool items, by display name (case-insensitive)."""
        for iid, iname in self.item_names.get(GAME, {}).items():
            if iname.lower() == name.lower():
                return self.item_grants.get(iid)
        return None

    async def grant_tool(self, name):
        """/tool failsafe: hand the game a tool directly, bypassing item-index dedup."""
        grant = self.tool_grant(name)
        if not grant:
            self.log(f"unknown tool '{name}'. Tools: {', '.join(sorted(self.tool_names))}")
            return
        if not self.game_writer:
            self.log("game isn't connected yet; grant will not apply")
            return
        await self.game_send({"type": "grant", "grant": grant, "text": f"Granted {name}"})
        self.log(f"granted {name} to the game")

    async def game_send_config(self):
        if self.session:
            await self.game_send({"type": "session", "session": self.session,
                                  "locations": list(self.location_keys),
                                  "difficulty": self.difficulty,
                                  "partyShuffle": self.party_shuffle})

    async def game_sync_items(self):
        if self.game_next_index is None:
            return
        while self.game_next_index < len(self.items_received):
            idx = self.game_next_index
            item_id, finder = self.items_received[idx]
            grant = self.item_grants.get(item_id, [])
            name = grant_label(grant)
            local_name = self.item_name(item_id, self.slot_num)
            sender = self.players.get(finder, "the server")
            # progression = tools or party members (highlight); a grant shows the
            # game's own "Found treasure!" box only if it hands over an actual
            # item/equip/spell — money/party/trap/reward grants are otherwise
            # silent, so those always need a banner or the pickup feels empty.
            is_progression = (local_name in self.tool_names
                              or any(g and g[0] == "party" for g in grant))
            has_popup = any(g and g[0] in ("i", "e", "s") for g in grant)
            self_announced = any(g and g[0] == "trap" for g in grant)  # mod toasts traps itself
            text = None
            if self.in_game_messages:
                if is_progression:
                    text = f"Got {local_name}!"          # progression highlight
                elif finder != self.slot_num:
                    text = f"Received {name} from {sender}"
                elif not has_popup and not self_announced:
                    text = f"Received {name}"             # silent grant → give feedback
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
                await self.eval_goal()
        elif t == "check":
            loc_id = self.location_keys.get(msg.get("location"))
            if loc_id is not None and loc_id not in self.checked:
                self.checked.add(loc_id)
                await self.send({"cmd": "LocationChecks", "locations": [loc_id]})
                self.log(f"check: {msg.get('location')} -> {loc_id}")
                info = self.locations_info.get(loc_id)
                if info and info[1] != self.slot_num:
                    who = self.players.get(info[1], "someone")
                    await self.banner(f"Sent {self.item_name(*info)} to {who}")
                await self.eval_goal()
        elif t == "death":
            if self.death_link:
                await self.send({"cmd": "Bounce", "tags": ["DeathLink"], "data": {
                    "time": time.time(), "source": self.slot,
                    "cause": f"{self.slot} was defeated"}})

    async def handle_command(self, line):
        line = line.strip()
        if not line:
            return
        if line in ("/help", "help", "?"):
            self.log("commands: /tool <name> — grant a tool (failsafe); /tools — list tools")
        elif line == "/tools":
            self.log("tools: " + ", ".join(sorted(self.tool_names)))
        elif line.startswith("/tool"):
            name = line[len("/tool"):].strip()
            if name:
                await self.grant_tool(name)
            else:
                self.log("usage: /tool <" + " | ".join(sorted(self.tool_names)) + ">")
        else:
            self.log(f"unknown command '{line}' (try /help)")

    async def console_input_loop(self):
        loop = asyncio.get_event_loop()
        while True:
            line = await loop.run_in_executor(None, sys.stdin.readline)
            if not line:                      # EOF (stdin closed)
                return
            await self.handle_command(line)

    async def run(self, with_console=False):
        server = await asyncio.start_server(self.handle_game, "127.0.0.1", self.game_port)
        self.log(f"waiting for the game on 127.0.0.1:{self.game_port}")
        if with_console:
            self.log("type /help for commands")
            asyncio.create_task(self.console_input_loop())
        async with server:
            await self.server_loop()


def main():
    # no arguments -> friendly GUI window; arguments -> console mode.
    if len(sys.argv) == 1:
        try:
            import ebf4_client_gui
            ebf4_client_gui.run_gui(Client, DEFAULT_GAME_PORT)
            return
        except Exception as e:  # tkinter missing/headless -> fall back to console help
            print(f"(GUI unavailable: {e}; pass args for console mode)")

    ap = argparse.ArgumentParser(description="EBF4 Archipelago console client")
    ap.add_argument("server", help="server host:port, e.g. localhost:38281")
    ap.add_argument("slot", help="your slot (player) name")
    ap.add_argument("password", nargs="?", default="", help="server password if any")
    ap.add_argument("--game-port", type=int, default=DEFAULT_GAME_PORT)
    args = ap.parse_args()

    client = Client(args.server, args.slot, args.password, args.game_port)
    try:
        asyncio.run(client.run(with_console=True))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
