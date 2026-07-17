"""Patch (or unpatch) a legally owned Steam copy of EBF4 with the Archipelago mod.

Never distributes game content: it modifies the user's own SWF in place,
keeping a pristine backup for reversal.

Usage:
  python patch.py                 # patch, using default Steam path
  python patch.py --restore       # restore the vanilla SWF from backup
  python patch.py --game-dir "D:\\Steam\\steamapps\\common\\Epic Battle Fantasy 4"
"""
import argparse
import hashlib
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
DEFAULT_GAME_DIR = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Epic Battle Fantasy 4")
SWF_NAME = "Epic Battle Fantasy 4.swf"
BACKUP_NAME = "Epic Battle Fantasy 4.vanilla.swf"
# Steam buildid 14083646
VANILLA_SHA256 = "baea1855d42cf5cf826e92059b5f480a6b23389ce40f1f04cbb0ac2f6feea957"
FFDEC_JAR = REPO / "tools-dl" / "ffdec" / "ffdec-cli.jar"
SCRIPTS_DIR = REPO / "gamemod" / "scripts"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game-dir", type=Path, default=DEFAULT_GAME_DIR)
    ap.add_argument("--ffdec-jar", type=Path, default=FFDEC_JAR)
    ap.add_argument("--restore", action="store_true")
    args = ap.parse_args()

    swf = args.game_dir / SWF_NAME
    backup = args.game_dir / BACKUP_NAME
    if not swf.exists():
        sys.exit(f"game SWF not found: {swf}")

    if args.restore:
        if not backup.exists():
            sys.exit("no backup found; nothing to restore")
        shutil.copy2(backup, swf)
        print(f"restored vanilla SWF (sha256 {sha256(swf)[:12]}...)")
        return

    if not args.ffdec_jar.exists():
        sys.exit(f"ffdec-cli.jar not found at {args.ffdec_jar}; download FFDec >= 24 and pass --ffdec-jar")

    digest = sha256(swf)
    if digest == VANILLA_SHA256:
        shutil.copy2(swf, backup)
        print("verified vanilla SWF, backup created")
    elif backup.exists() and sha256(backup) == VANILLA_SHA256:
        print("SWF already modified; re-patching from verified backup")
    else:
        sys.exit(f"SWF hash {digest[:12]}... is not the known vanilla build and no clean backup exists.\n"
                 "Verify game files in Steam, then re-run.")

    out = swf.with_suffix(".patched.swf")
    cmd = ["java", "-Xmx6g", "-jar", str(args.ffdec_jar),
           "-importScript", str(backup), str(out), str(SCRIPTS_DIR)]
    print("running:", " ".join(cmd))
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0 or not out.exists():
        print(res.stdout, res.stderr)
        sys.exit("ffdec import failed")
    shutil.move(out, swf)
    print(f"patched OK -> {swf}")
    print("restore anytime with: python tools/patch.py --restore")


if __name__ == "__main__":
    main()
