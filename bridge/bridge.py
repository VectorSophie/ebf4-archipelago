"""Minimal test bridge for the EBF4 Archipelago mod.

Speaks the mod's framing: 4-byte big-endian length prefix + UTF-8 JSON.
Not a real Archipelago client yet - it logs everything the game sends and
lets you push test items from stdin.

Usage:  python bridge.py [--port 26510] [--auto-item]
Stdin commands while running:
  item [amount]   send a money item with the next index
  ping            send a ping (game answers pong)
  quit
"""
import argparse
import asyncio
import json
import struct
import sys
import time

# ponytail: single-connection, in-memory state; real AP client comes later.
class Bridge:
    def __init__(self, auto_item: bool, dup_test: bool = False):
        self.auto_item = auto_item
        self.dup_test = dup_test
        self.writer = None
        self.next_index = 0   # taken from the game's hello
        self.checks = []

    def log(self, msg):
        print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)

    def send(self, obj):
        if not self.writer:
            self.log("no game connected")
            return
        data = json.dumps(obj).encode("utf-8")
        self.writer.write(struct.pack(">I", len(data)) + data)
        self.log(f"-> {obj}")

    def send_item(self, amount=100):
        self.send({"type": "item", "index": self.next_index,
                   "item": "money", "amount": amount})
        self.next_index += 1

    async def handle(self, reader, writer):
        peer = writer.get_extra_info("peername")
        self.log(f"game connected from {peer}")
        self.writer = writer
        try:
            while True:
                header = await reader.readexactly(4)
                (length,) = struct.unpack(">I", header)
                payload = await reader.readexactly(length)
                msg = json.loads(payload.decode("utf-8"))
                self.log(f"<- {msg}")
                if msg.get("type") == "hello":
                    self.next_index = int(msg.get("itemIndex", 0))
                    self.log(f"game reports next item index {self.next_index}")
                    if self.auto_item:
                        self.send_item()
                    if self.dup_test:
                        # deliberately resend index 0 - the game must skip it
                        self.send({"type": "item", "index": 0,
                                   "item": "money", "amount": 100})
                elif msg.get("type") == "check":
                    loc = msg.get("location")
                    dup = loc in self.checks
                    self.checks.append(loc)
                    self.log(f"CHECK {loc}{' (duplicate)' if dup else ''}")
        except (asyncio.IncompleteReadError, ConnectionResetError):
            self.log("game disconnected")
        finally:
            if self.writer is writer:
                self.writer = None

    async def stdin_loop(self):
        loop = asyncio.get_event_loop()
        while True:
            line = await loop.run_in_executor(None, sys.stdin.readline)
            if not line:
                await asyncio.sleep(3600)  # stdin closed (background run)
                continue
            parts = line.split()
            if not parts:
                continue
            if parts[0] == "item":
                self.send_item(int(parts[1]) if len(parts) > 1 else 100)
            elif parts[0] == "ping":
                self.send({"type": "ping"})
            elif parts[0] == "quit":
                sys.exit(0)


async def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=26510)
    ap.add_argument("--auto-item", action="store_true",
                    help="send one 100-gold test item when the game says hello")
    ap.add_argument("--dup-test", action="store_true",
                    help="also resend item index 0 on hello (must be skipped by the game)")
    args = ap.parse_args()
    bridge = Bridge(args.auto_item, args.dup_test)
    server = await asyncio.start_server(bridge.handle, "127.0.0.1", args.port)
    bridge.log(f"listening on 127.0.0.1:{args.port}")
    asyncio.ensure_future(bridge.stdin_loop())
    async with server:
        await server.serve_forever()


if __name__ == "__main__":
    asyncio.run(main())
