"""Read-only equivalent of the Arch update counter for pinned GitHub inputs."""

import concurrent.futures
import html
import json
import pathlib
import sys
import urllib.parse
import urllib.request


def check_input(item):
    name, node = item
    original, locked = node["original"], node["locked"]
    ref = urllib.parse.quote(original.get("ref", "HEAD"), safe="")
    url = f'https://api.github.com/repos/{original["owner"]}/{original["repo"]}/commits/{ref}'
    request = urllib.request.Request(url, headers={"User-Agent": "waybar-nix-updates", "Accept": "application/vnd.github+json"})
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            revision = json.load(response)["sha"]
        return name, locked["rev"], revision, None
    except Exception as error:
        return name, locked["rev"], None, str(error)


def main(lock_path):
    lock = json.loads(pathlib.Path(lock_path).read_text())
    nodes = lock["nodes"]
    candidates = []
    for name, target in nodes[lock["root"]]["inputs"].items():
        if not isinstance(target, str):
            continue
        node = nodes[target]
        original = node.get("original", {})
        if original.get("type") == "github" and "rev" not in original:
            candidates.append((name, node))
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(check_input, candidates))
    changed = [(name, old, new) for name, old, new, error in results if new and old != new]
    failed = [name for name, _, _, error in results if error]
    tooltip = ["<b>Nix flake input updates</b>", "Counts inputs, not individual packages."]
    tooltip.extend(html.escape(f"{name}: {old[:7]} → {new[:7]}") for name, old, new in changed)
    if failed:
        tooltip.append(html.escape("Unavailable: " + ", ".join(failed)))
    print(json.dumps({"text": str(len(changed)) if changed else ("?" if failed else ""), "tooltip": "\n".join(tooltip), "class": "error" if failed else "updates"}))


if __name__ == "__main__":
    main(sys.argv[1])
