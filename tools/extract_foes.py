"""Parse Foes.as -> apworld/ebf4/data/foes.json (id + English name).

A foe's runtime id is getQualifiedClassName(foe).split("::")[1].lower(), which
equals the Foes.as static-var name (e.g. batblood). Bestiary locations are
filler-only (see data.py). ~147 scannable foes.
"""
import json
import re
import pathlib

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "reference" / "ebf4-decompile" / "scripts" / "default_package" / "Foes.as"
OUT = REPO / "apworld" / "ebf4" / "data" / "foes.json"

FOE = re.compile(
    r'public static var (\w+):Object\s*=\s*\{\s*"name"\s*:\s*\[\s*"((?:[^"\\]|\\.)*)"')


def main():
    text = SRC.read_text(encoding="utf-8", errors="replace")
    foes = {}
    for fid, name in FOE.findall(text):
        foes[fid.lower()] = name.encode().decode("unicode_escape")
    OUT.write_text(json.dumps(foes, indent=1, ensure_ascii=False), encoding="utf-8")
    print(f"foes={len(foes)}")


if __name__ == "__main__":
    main()
