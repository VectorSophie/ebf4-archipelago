"""Assemble the player-facing distribution zip.

Bundles exactly what a friend needs — the world, the patcher, the mod scripts,
and the guide. No copyrighted game assets are included.

  python tools/make_dist.py   ->  build/ebf4-ap-<version>.zip
"""
import json
import shutil
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUILD = REPO / "build"
STAGE = BUILD / "ebf4-ap-dist"

VERSION = json.loads((REPO / "apworld" / "ebf4" / "archipelago.json").read_text())["world_version"]


def main():
    # (re)build the .apworld
    apworld_zip = BUILD / "ebf4.zip"
    shutil.make_archive(str(BUILD / "ebf4"), "zip", REPO / "apworld", "ebf4")
    apworld = BUILD / "ebf4.apworld"
    apworld_zip.replace(apworld)

    if STAGE.exists():
        shutil.rmtree(STAGE)
    STAGE.mkdir(parents=True)

    shutil.copy2(apworld, STAGE / "ebf4.apworld")
    shutil.copy2(REPO / "ebf4_client.py", STAGE / "ebf4_client.py")
    shutil.copy2(REPO / "ebf4_client_gui.py", STAGE / "ebf4_client_gui.py")
    shutil.copy2(REPO / "ebf4_client.pyw", STAGE / "ebf4_client.pyw")
    shutil.copy2(REPO / "SETUP.md", STAGE / "SETUP.md")
    shutil.copy2(REPO / "ebf4_example.yaml", STAGE / "ebf4_example.yaml")
    (STAGE / "tools").mkdir()
    shutil.copy2(REPO / "tools" / "patch.py", STAGE / "tools" / "patch.py")
    shutil.copytree(REPO / "gamemod" / "scripts", STAGE / "gamemod" / "scripts")

    out = BUILD / f"ebf4-ap-{VERSION}"
    out_zip = BUILD / f"ebf4-ap-{VERSION}.zip"
    if out_zip.exists():
        out_zip.unlink()
    shutil.make_archive(str(out), "zip", STAGE)
    print(f"wrote {out_zip}")
    print("contents:")
    for p in sorted(STAGE.rglob("*")):
        if p.is_file():
            print("  " + str(p.relative_to(STAGE)).replace("\\", "/"))


if __name__ == "__main__":
    main()
