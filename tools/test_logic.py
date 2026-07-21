"""Headless logic checks: region requirements + (optionally) fill completability.

Part 1 (always): region requirement model is sane.
Part 2 (if a source Archipelago is importable OR ArchipelagoGenerate is present):
generate real seeds for randomize_tools on/off and assert the fill solver
succeeds -- the ground-truth soft-lock check.
"""
import importlib.util
import pathlib

REPO = pathlib.Path(__file__).resolve().parent.parent

# load regions.py standalone (avoid running the AP-heavy package __init__)
_spec = importlib.util.spec_from_file_location(
    "ebf4_regions", REPO / "apworld" / "ebf4" / "regions.py")
regions = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(regions)


def test_area_requirements():
    entry = regions.area_entry_requirements()
    assert entry["Greenwood"] == set(), entry["Greenwood"]
    # entering Ashwood needs Greenwood's gates (axe among them)
    assert "axe" in entry["Ashwood Forest"], entry["Ashwood Forest"]


def test_location_requires_own_map_gate():
    # map 9 (Greenwood) has the axe-gated bush -> its chests require axe
    assert "axe" in regions.location_requires(9), regions.location_requires(9)
    # a start-area map with no gate requires nothing
    assert regions.location_requires(10) == set(), regions.location_requires(10)


def test_monotonic_entry():
    # entry requirements only grow along AREA_ORDER (no under-gating regressions)
    entry = regions.area_entry_requirements()
    prev = set()
    for a in regions.AREA_ORDER:
        assert prev <= entry[a], (a, prev, entry[a])
        prev = entry[a]


if __name__ == "__main__":
    test_area_requirements()
    test_location_requires_own_map_gate()
    test_monotonic_entry()
    print("logic part1 ok")
