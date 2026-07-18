"""EBF4 Archipelago client, packaged as a Launcher component.

Bridges the patched game (length-prefixed JSON over 127.0.0.1:26510, protocol v2)
to an Archipelago server. Runs from the AP Launcher as "EBF4 Client".
"""
import asyncio
import json
import struct
import typing

from CommonClient import (CommonContext, get_base_parser, gui_enabled, logger,
                          server_loop)
from NetUtils import ClientStatus

GAME = "Epic Battle Fantasy 4"
DEFAULT_GAME_PORT = 26510


class EBF4Context(CommonContext):
    game = GAME
    items_handling = 0b111  # remote items: the server is the source of truth
    tags = {"AP"}

    def __init__(self, server_address, password, game_port):
        super().__init__(server_address, password)
        self.game_port = game_port
        self.game_writer = None
        self.game_server = None
        self.game_next_index = None   # next item index the game expects (from hello)
        self.session = None           # seed_name:slot, scopes the game's item index
        self.location_keys = {}       # "chest_9_0" -> AP location id (slot_data)
        self.item_grants = {}         # AP item id -> grant list (slot_data)
        self.goal_count = 0
        self.goal_sent = False

    async def server_auth(self, password_requested: bool = False):
        if password_requested and not self.password:
            await super().server_auth(password_requested)
        await self.get_username()
        await self.send_connect()

    def on_package(self, cmd, args):
        if cmd == "RoomInfo":
            self.seed_name = args.get("seed_name")
        elif cmd == "Connected":
            slot_data = args.get("slot_data") or {}
            self.location_keys = slot_data.get("location_keys", {})
            self.item_grants = {int(k): v for k, v in
                                slot_data.get("item_grants", {}).items()}
            self.goal_count = int(slot_data.get("goal_count", len(self.item_grants)))
            self.session = f"{self.seed_name}:{self.slot}"
            if slot_data.get("death_link"):
                self.tags.add("DeathLink")
                asyncio.create_task(self.update_death_link(True))
            logger.info(f"EBF4: session {self.session}, "
                        f"{len(self.location_keys)} managed locations, "
                        f"goal {self.goal_count}")
            self.game_send_config()
            if self.location_keys:
                asyncio.create_task(self.send_msgs([{
                    "cmd": "LocationScouts",
                    "locations": list(self.location_keys.values()),
                    "create_as_hint": 0}]))
        elif cmd == "ReceivedItems":
            self.game_sync_items()
            self.check_goal()

    def on_deathlink(self, data):
        super().on_deathlink(data)
        self.game_send({"type": "deathlink",
                        "source": data.get("source", "someone")})

    # ---- game socket ----

    def game_send(self, obj):
        if not self.game_writer:
            return
        try:
            data = json.dumps(obj).encode("utf-8")
            self.game_writer.write(struct.pack(">I", len(data)) + data)
        except Exception as e:
            logger.error(f"EBF4: send failed: {e}")

    def game_send_config(self):
        if self.session:
            self.game_send({"type": "session", "session": self.session,
                            "locations": list(self.location_keys)})

    def game_sync_items(self):
        if self.game_next_index is None:
            return
        while self.game_next_index < len(self.items_received):
            idx = self.game_next_index
            net_item = self.items_received[idx]
            grant = self.item_grants.get(net_item.item)
            name = self.item_names.lookup_in_game(net_item.item)
            sender = self.player_names.get(net_item.player, "the server")
            text = (f"Received {name} from {sender}"
                    if net_item.player != self.slot else None)
            self.game_send({"type": "item", "index": idx, "name": name,
                            "text": text, "grant": grant or []})
            logger.info(f"EBF4: sent item {idx}: {name}")
            self.game_next_index += 1

    def check_goal(self):
        if self.goal_sent or not self.goal_count:
            return
        received = {i.item for i in self.items_received}
        if len(received) >= self.goal_count:
            self.goal_sent = True
            logger.info("EBF4: goal complete!")
            asyncio.create_task(self.send_msgs(
                [{"cmd": "StatusUpdate", "status": ClientStatus.CLIENT_GOAL}]))
            self.game_send({"type": "msg", "text": "GOAL! You win!"})

    async def handle_game(self, reader, writer):
        logger.info(f"EBF4: game connected from {writer.get_extra_info('peername')}")
        self.game_writer = writer
        try:
            while True:
                header = await reader.readexactly(4)
                (length,) = struct.unpack(">I", header)
                msg = json.loads((await reader.readexactly(length)).decode("utf-8"))
                await self.handle_game_msg(msg)
        except (asyncio.IncompleteReadError, ConnectionResetError):
            logger.info("EBF4: game disconnected")
        finally:
            if self.game_writer is writer:
                self.game_writer = None
                self.game_next_index = None

    async def handle_game_msg(self, msg):
        t = msg.get("type")
        if t == "hello":
            self.game_send_config()
            if self.session and msg.get("session", "") == self.session:
                self.game_next_index = int(msg.get("itemIndex", 0))
                logger.info(f"EBF4: game in session, next item index {self.game_next_index}")
                self.game_sync_items()
                self.check_goal()
        elif t == "check":
            key = msg.get("location")
            loc_id = self.location_keys.get(key)
            if loc_id is None:
                return
            new = loc_id not in self.checked_locations
            await self.check_locations([loc_id])
            if new:
                scouted = self.locations_info.get(loc_id)
                if scouted and scouted.player != self.slot:
                    item = self.item_names.lookup_in_slot(scouted.item, scouted.player)
                    receiver = self.player_names.get(scouted.player, "?")
                    self.game_send({"type": "msg", "text": f"Sent {item} to {receiver}"})
        elif t == "death":
            if "DeathLink" in self.tags:
                await self.send_death(
                    f"{self.player_names.get(self.slot, 'EBF4')} was defeated")

    def run_gui(self):
        from kvui import GameManager

        class EBF4Manager(GameManager):
            logging_pairs = [("Client", "Archipelago")]
            base_title = "Epic Battle Fantasy 4 Client"

        self.ui = EBF4Manager(self)
        self.ui_task = asyncio.create_task(self.ui.async_run(), name="UI")


async def _main(args):
    ctx = EBF4Context(args.connect, args.password, args.game_port)
    ctx.server_task = asyncio.create_task(server_loop(ctx), name="ServerLoop")
    if gui_enabled:
        ctx.run_gui()
    ctx.run_cli()
    ctx.game_server = await asyncio.start_server(
        ctx.handle_game, "127.0.0.1", ctx.game_port)
    logger.info(f"EBF4: waiting for the game on 127.0.0.1:{ctx.game_port}")
    await ctx.exit_event.wait()
    ctx.game_server.close()
    await ctx.shutdown()


def launch(*args):
    import Utils
    Utils.init_logging("EBF4Client", exception_logger="Client")

    parser = get_base_parser(description="EBF4 Archipelago Client")
    parser.add_argument("--game-port", type=int, default=DEFAULT_GAME_PORT,
                        help="local TCP port the patched game connects to")
    ns = parser.parse_args(args)

    async def run():
        await _main(ns)

    import colorama
    colorama.just_fix_windows_console()
    asyncio.run(run())
    colorama.deinit()
