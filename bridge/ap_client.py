"""EBF4 Archipelago client.

Bridges the patched game (length-prefixed JSON over localhost TCP, see README)
to an Archipelago server via CommonClient.

Usage (from repo root):
  python bridge/ap_client.py --connect localhost:38281 --name Sophie [--game-port 26510]

Requires a local Archipelago checkout; set AP_REPO or keep the default
reference/Archipelago layout.
"""
import asyncio
import json
import os
import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
AP_REPO = Path(os.environ.get("AP_REPO", REPO / "reference" / "Archipelago"))
os.environ.setdefault("SKIP_REQUIREMENTS_UPDATE", "1")
sys.path.insert(0, str(AP_REPO))

from CommonClient import CommonContext, get_base_parser, logger, server_loop  # noqa: E402


class EBF4Context(CommonContext):
    game = "Epic Battle Fantasy 4"
    items_handling = 0b111  # remote items: the server is the source of truth

    def __init__(self, server_address, password):
        super().__init__(server_address, password)
        self.game_writer = None
        self.game_next_index = None   # next item index the game expects (from hello)
        self.location_keys = {}       # "chest_9_0" -> AP location id (slot_data)
        self.item_grants = {}         # AP item id -> grant list (slot_data)
        self.session = None           # seed_name:slot, scopes the game's item index

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
            self.session = f"{self.seed_name}:{self.slot}"
            logger.info(f"EBF4: session {self.session}, "
                        f"{len(self.location_keys)} managed locations")
            self.game_send_config()
        elif cmd == "ReceivedItems":
            self.game_sync_items()

    # ---- game socket ----

    def game_send(self, obj):
        if not self.game_writer:
            return
        data = json.dumps(obj).encode("utf-8")
        self.game_writer.write(struct.pack(">I", len(data)) + data)

    def game_send_config(self):
        if self.session:
            self.game_send({"type": "session", "session": self.session,
                            "locations": list(self.location_keys)})

    def game_sync_items(self):
        """Send every received item the game hasn't applied yet."""
        if self.game_next_index is None:
            return
        while self.game_next_index < len(self.items_received):
            idx = self.game_next_index
            net_item = self.items_received[idx]
            grant = self.item_grants.get(net_item.item)
            name = self.item_names.lookup_in_game(net_item.item)
            if grant is None:
                logger.warning(f"EBF4: no grant data for item {name}, skipping")
            self.game_send({"type": "item", "index": idx,
                            "name": name, "grant": grant or []})
            logger.info(f"EBF4: sent item {idx}: {name}")
            self.game_next_index += 1

    async def handle_game(self, reader, writer):
        peer = writer.get_extra_info("peername")
        logger.info(f"EBF4: game connected from {peer}")
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
            game_session = msg.get("session", "")
            if self.session and game_session == self.session:
                # game confirmed our session: safe to replay from its index
                self.game_next_index = int(msg.get("itemIndex", 0))
                logger.info(f"EBF4: game in session, next item index {self.game_next_index}")
                self.game_sync_items()
            else:
                logger.info("EBF4: game hello, sending session config")
                self.game_send_config()
        elif t == "check":
            key = msg.get("location")
            loc_id = self.location_keys.get(key)
            if loc_id is None:
                logger.info(f"EBF4: ignoring non-managed location {key}")
                return
            logger.info(f"EBF4: check {key} -> {loc_id}")
            await self.check_locations([loc_id])


async def main():
    import Utils
    Utils.init_logging("EBF4Client")
    parser = get_base_parser(description="EBF4 Archipelago client")
    parser.add_argument("--name", default=None, help="slot name")
    parser.add_argument("--game-port", type=int, default=26510)
    args = parser.parse_args()

    ctx = EBF4Context(args.connect, args.password)
    if args.name:
        ctx.auth = args.name
    ctx.server_task = asyncio.create_task(server_loop(ctx), name="server loop")

    game_server = await asyncio.start_server(ctx.handle_game, "127.0.0.1", args.game_port)
    logger.info(f"EBF4: listening for the game on 127.0.0.1:{args.game_port}")

    await ctx.exit_event.wait()
    game_server.close()
    await ctx.shutdown()


if __name__ == "__main__":
    asyncio.run(main())
