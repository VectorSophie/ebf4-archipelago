"""Headless checks for ebf4_client command handling (no server/game needed)."""
import asyncio
import json
import pathlib
import struct
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO))
import ebf4_client as C


class FakeWriter:
    def __init__(self):
        self.frames = []
        self._buf = b""

    def write(self, data):
        self._buf += data
        # decode any complete length-prefixed frames
        while len(self._buf) >= 4:
            (n,) = struct.unpack(">I", self._buf[:4])
            if len(self._buf) < 4 + n:
                break
            self.frames.append(json.loads(self._buf[4:4 + n].decode("utf-8")))
            self._buf = self._buf[4 + n:]

    async def drain(self):
        pass


def make_client():
    c = C.Client("h:1", "slot", "", C.DEFAULT_GAME_PORT, log_sink=lambda _m: None)
    # what DataPackage + slot_data would give us for our own game
    c.item_names[C.GAME] = {500: "Axe", 501: "Candle"}
    c.item_grants = {500: [["i", "axe", 1]], 501: [["i", "candle", 1]]}
    return c


def test_tool_grant_resolves_and_sends():
    c = make_client()
    w = FakeWriter()
    c.game_writer = w
    asyncio.run(c.handle_command("/tool Axe"))
    assert len(w.frames) == 1, w.frames
    f = w.frames[0]
    assert f["type"] == "grant" and f["grant"] == [["i", "axe", 1]], f


def test_tool_case_insensitive():
    c = make_client()
    c.game_writer = FakeWriter()
    asyncio.run(c.handle_command("/tool  candle "))
    assert c.game_writer.frames[0]["grant"] == [["i", "candle", 1]]


def test_unknown_tool_sends_nothing():
    c = make_client()
    c.game_writer = FakeWriter()
    asyncio.run(c.handle_command("/tool Nope"))
    assert c.game_writer.frames == []


def test_grant_without_game_sends_nothing():
    c = make_client()
    c.game_writer = None  # game not connected
    asyncio.run(c.grant_tool("Axe"))  # must not raise


def test_grant_labels():
    assert C.grant_label([["party", "natalie", 0]]) == "Natalie"
    assert C.grant_label([["trap", "goldloss", 0]]) == "goldloss trap"
    assert C.grant_label([["money", "", 100]]) == "100 gold"
    assert C.grant_label([["i", "turnip", 3]]) == "turnip x3"


def _sync_texts(items_received, item_grants, item_names, tool_names=None):
    """Run game_sync_items over the given received items; return the banner text
    of each emitted frame (None = silent, treasure box only)."""
    c = make_client()
    c.item_grants = item_grants
    c.item_names[C.GAME] = item_names
    if tool_names is not None:
        c.tool_names = tool_names
    c.slot_num = 1
    c.players = {1: "Player1", 2: "Ally"}
    c.player_game = {1: C.GAME, 2: C.GAME}
    c.items_received = items_received
    c.game_writer = FakeWriter()
    c.game_next_index = 0
    asyncio.run(c.game_sync_items())
    return [f.get("text") for f in c.game_writer.frames]


def test_feedback_party_and_silent_grants():
    grants = {10: [["party", "lance", 0]], 11: [["money", "", 800]],
              12: [["i", "turnip", 3]]}
    names = {10: "Lance", 11: "Battle Reward (26-0)", 12: "3x turnip (9-0)"}
    # all found by self (solo) -> party highlights, money gets a banner, bundle
    # is silent (the game's own treasure box shows it)
    texts = _sync_texts([(10, 1), (11, 1), (12, 1)], grants, names,
                        tool_names={"Axe"})
    assert texts[0] == "Got Lance!"          # party member highlighted
    assert texts[1] == "Received 800 gold"   # silent grant now has feedback
    assert texts[2] is None                  # bundle -> treasure box only


if __name__ == "__main__":
    test_tool_grant_resolves_and_sends()
    test_tool_case_insensitive()
    test_unknown_tool_sends_nothing()
    test_grant_without_game_sends_nothing()
    test_grant_labels()
    test_feedback_party_and_silent_grants()
    print("client ok")
