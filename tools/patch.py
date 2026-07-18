"""Patch (or restore) a legally owned Steam copy of EBF4 with the Archipelago mod.

Never distributes game content: it modifies YOUR OWN installed SWF in place and
keeps a pristine backup for one-command restore. Auto-downloads FFDec (the SWF
tool) on first run, so you only need Java + Python.

Usage:
  python tools/patch.py                # find the game, patch it (backs up first)
  python tools/patch.py --restore      # restore the vanilla SWF from backup
  python tools/patch.py --game-dir "D:\\SteamLibrary\\steamapps\\common\\Epic Battle Fantasy 4"
"""
import argparse
import hashlib
import io
import os
import re
import shutil
import subprocess
import sys
import urllib.request
import zipfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SWF_NAME = "Epic Battle Fantasy 4.swf"
BACKUP_NAME = "Epic Battle Fantasy 4.vanilla.swf"
# Steam buildid 14083646
VANILLA_SHA256 = "baea1855d42cf5cf826e92059b5f480a6b23389ce40f1f04cbb0ac2f6feea957"
SCRIPTS_DIR = REPO / "gamemod" / "scripts"
FFDEC_DIR = REPO / "tools-dl" / "ffdec"
FFDEC_JAR = FFDEC_DIR / "ffdec-cli.jar"
FFDEC_URL = ("https://github.com/jindrapetrik/jpexs-decompiler/releases/download/"
             "version24.1.2/ffdec_24.1.2.zip")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def find_game_dir() -> Path | None:
    """Locate the EBF4 install: common paths, then every Steam library folder."""
    candidates = []
    for base in (r"C:\Program Files (x86)\Steam", r"C:\Program Files\Steam",
                 os.path.expanduser("~/.steam/steam"),
                 os.path.expanduser("~/.local/share/Steam")):
        vdf = Path(base) / "steamapps" / "libraryfolders.vdf"
        candidates.append(Path(base) / "steamapps" / "common" / "Epic Battle Fantasy 4")
        if vdf.exists():
            for lib in re.findall(r'"path"\s*"([^"]+)"', vdf.read_text(encoding="utf-8", errors="replace")):
                candidates.append(Path(lib.replace("\\\\", "\\")) /
                                  "steamapps" / "common" / "Epic Battle Fantasy 4")
    for c in candidates:
        if (c / SWF_NAME).exists():
            return c
    return None


def ensure_ffdec() -> Path:
    if FFDEC_JAR.exists():
        return FFDEC_JAR
    print(f"FFDec not found; downloading {FFDEC_URL} ...")
    FFDEC_DIR.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(FFDEC_URL) as r:
        data = r.read()
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        z.extractall(FFDEC_DIR)
    if not FFDEC_JAR.exists():
        sys.exit(f"FFDec download did not yield {FFDEC_JAR}")
    print("FFDec ready.")
    return FFDEC_JAR


def require_java():
    if shutil.which("java") is None:
        sys.exit("Java not found on PATH. Install Java 8+ (e.g. Temurin) and retry.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game-dir", type=Path, default=None,
                    help="EBF4 install folder (auto-detected if omitted)")
    ap.add_argument("--ffdec-jar", type=Path, default=None)
    ap.add_argument("--restore", action="store_true")
    args = ap.parse_args()

    game_dir = args.game_dir or find_game_dir()
    if not game_dir or not (game_dir / SWF_NAME).exists():
        sys.exit("Could not find 'Epic Battle Fantasy 4.swf'. Pass --game-dir "
                 "pointing at your EBF4 install folder.")
    swf = game_dir / SWF_NAME
    backup = game_dir / BACKUP_NAME

    if args.restore:
        if not backup.exists():
            sys.exit("No backup found; nothing to restore.")
        shutil.copy2(backup, swf)
        print(f"Restored vanilla SWF (sha256 {sha256(swf)[:12]}...).")
        return

    require_java()
    ffdec = args.ffdec_jar or ensure_ffdec()

    digest = sha256(swf)
    if digest == VANILLA_SHA256:
        shutil.copy2(swf, backup)
        print("Verified vanilla SWF; backup created.")
    elif backup.exists() and sha256(backup) == VANILLA_SHA256:
        print("SWF already modified; re-patching from the verified backup.")
    else:
        sys.exit(f"SWF hash {digest[:12]}... is not the known vanilla build "
                 f"(expected {VANILLA_SHA256[:12]}...) and no clean backup exists.\n"
                 "In Steam: right-click EBF4 > Properties > Installed Files > "
                 "Verify integrity, then re-run. (This mod targets Steam build 14083646.)")

    out = swf.with_suffix(".patched.swf")
    cmd = ["java", "-Xmx6g", "-jar", str(ffdec),
           "-importScript", str(backup), str(out), str(SCRIPTS_DIR)]
    print("Running FFDec import...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0 or not out.exists():
        print(res.stdout, res.stderr)
        sys.exit("FFDec import failed.")
    shutil.move(out, swf)
    print(f"Patched OK -> {swf}")
    print("Restore anytime with: python tools/patch.py --restore")


if __name__ == "__main__":
    main()
