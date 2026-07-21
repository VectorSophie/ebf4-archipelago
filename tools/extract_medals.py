"""Parse Medals.as -> apworld/ebf4/data/medals.json (id + English display name).

Medals are filler-only AP locations (earn one = a check); see data.py.
"""
import json
import re
import pathlib

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "reference" / "ebf4-decompile" / "scripts" / "default_package" / "Medals.as"
OUT = REPO / "apworld" / "ebf4" / "data" / "medals.json"

# each medal object literal is `{ "id":"x", "name":["English", ...], ... }`
BLOCK = re.compile(r'"id"\s*:\s*"([A-Za-z0-9_]+)"\s*,\s*"name"\s*:\s*\[\s*"((?:[^"\\]|\\.)*)"')


def main():
    text = SRC.read_text(encoding="utf-8", errors="replace")
    medals = {}
    for mid, name in BLOCK.findall(text):
        medals[mid] = name.encode().decode("unicode_escape")
    OUT.write_text(json.dumps(medals, indent=1, ensure_ascii=False), encoding="utf-8")
    print(f"medals={len(medals)}")


if __name__ == "__main__":
    main()
