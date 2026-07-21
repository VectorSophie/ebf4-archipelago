"""Headless check that extract_map.py produces a sane region graph."""
import json
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent


def test_regions_json_shape():
    subprocess.run([sys.executable, str(REPO / "tools" / "extract_map.py")], check=True)
    data = json.loads((REPO / "apworld" / "ebf4" / "data" / "regions.json").read_text())
    assert "regions" in data and "edges" in data and "map_to_area" in data
    assert "map_requires" in data
    chests = json.loads((REPO / "apworld" / "ebf4" / "data" / "chests.json").read_text())
    maps = {str(c["map"]) for c in chests}
    missing = maps - set(data["map_to_area"].keys())
    assert not missing, f"chest maps missing from map_to_area: {sorted(missing)}"
    for e in data["edges"]:
        assert isinstance(e["requires"], list)
        assert "from" in e and "to" in e
    # sanity: at least the known gating items appear somewhere in map_requires
    all_reqs = {i for v in data["map_requires"].values() for i in v}
    assert {"axe", "candle"} & all_reqs, f"expected tool gates, got {sorted(all_reqs)}"


if __name__ == "__main__":
    test_regions_json_shape()
    print("ok")
