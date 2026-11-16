import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

STATES = {"enabled": "On", "muted": "Silent", "ignored": "Off"}
CYCLE = ("enabled", "muted", "ignored")
DENY = frozenset({"notify-send", "swaync-app-rules", "swaync", "SwayNC"})
ROW = re.compile(r"(?P<app>.+?) {2}\[(?P<label>On|Silent|Off)\]")
ROTATE_BYTES = 512 * 1024
ROTATE_KEEP = 1000


def state_dir():
    root = os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state")
    return Path(root) / "swaync"


def catalogue_path():
    return state_dir() / "apps.log"


def rules_path():
    return state_dir() / "rules.json"


def config_path():
    return state_dir() / "config.json"


def read_rules(path):
    try:
        data = json.loads(Path(path).read_text())
    except (OSError, ValueError):
        return {}
    apps = data.get("apps") if isinstance(data, dict) else None
    if not isinstance(apps, dict):
        return {}
    return {name: state for name, state in apps.items() if state in STATES}


def write_rules(path, rules):
    payload = {"version": 1, "apps": dict(sorted(rules.items()))}
    write_atomic(path, json.dumps(payload, ensure_ascii=False, indent=2) + "\n")


def write_atomic(path, text):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.")
    try:
        with os.fdopen(handle, "w") as file:
            file.write(text)
        os.replace(temporary, path)
    except BaseException:
        os.unlink(temporary)
        raise


def next_state(state):
    index = CYCLE.index(state) if state in CYCLE else len(CYCLE) - 1
    return CYCLE[(index + 1) % len(CYCLE)]


def escape_regex(text):
    """Escape regex metacharacters, leaving spaces readable in the config."""
    return re.sub(r"([\\.^$*+?()\[\]{}|])", r"\\\1", text)


def visibility_entries(rules):
    entries = {}
    for index, name in enumerate(sorted(rules)):
        if rules[name] == "enabled":
            continue
        entries[f"swaync-app-rules-{index}"] = {
            "app-name": escape_regex(name),
            "state": rules[name],
        }
    return entries


def merge_config(base, rules):
    config = dict(base)
    before = config.get("notification-visibility")
    kept = {
        key: value
        for key, value in (before or {}).items()
        if not key.startswith("swaync-app-rules-")
    }
    merged = {**kept, **visibility_entries(rules)}
    if merged:
        config["notification-visibility"] = merged
    else:
        config.pop("notification-visibility", None)
    return config


def format_row(name, state):
    return f"{name}  [{STATES[state]}]"


def parse_row(row, rules):
    match = ROW.fullmatch(row)
    if match is None:
        return row.strip(), rules.get(row.strip(), "enabled")
    name = match.group("app")
    return name, rules.get(name, "enabled")


def recent_apps(lines, rules, limit=30):
    seen = dict(rules)
    order = sorted(rules)
    for line in reversed(lines):
        name = line.split("\t")[0].strip()
        if not name or name in DENY or name in seen:
            continue
        seen[name] = "enabled"
        order.append(name)
        if len(order) >= limit:
            break
    return order[:limit]


def read_catalogue(path):
    try:
        return Path(path).read_text(errors="replace").splitlines()
    except OSError:
        return []


def record(path, name, now=None):
    name = (name or "").strip()
    if not name or name in DENY or len(name) > 120 or any(c in name for c in "\t\n"):
        return False
    stamp = int(time.time() if now is None else now)
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as file:
        file.write(f"{name}\t{stamp}\n")
    try:
        if path.stat().st_size > ROTATE_BYTES:
            kept = path.read_text(errors="replace").splitlines()[-ROTATE_KEEP:]
            write_atomic(path, "\n".join(kept) + "\n")
    except OSError:
        pass
    return True


def apply(base_path, rules, target=None):
    base = json.loads(Path(base_path).read_text())
    merged = merge_config(base, rules)
    write_atomic(target or config_path(), json.dumps(merged, ensure_ascii=False, indent=2) + "\n")


def reload_daemon():
    subprocess.run(["swaync-client", "--reload-config"], check=False, timeout=10)


def notify(summary, body):
    subprocess.run(["notify-send", summary, body], check=False, timeout=10)


def base_path(argument):
    if argument:
        return argument
    configured = os.environ.get("SWAYNC_BASE_CONFIG")
    if configured:
        return configured
    try:
        return (state_dir() / "base-path").read_text().strip()
    except OSError:
        raise SystemExit("no base config configured")


def main():
    action, *rest = sys.argv[1:] or ["pick"]
    base = None
    if "--base" in rest:
        index = rest.index("--base")
        base = rest[index + 1]
        del rest[index : index + 2]

    if action == "record":
        record(catalogue_path(), os.environ.get("SWAYNC_APP_NAME", ""))
        return 0

    if action == "apply":
        apply(base_path(base), read_rules(rules_path()))
        if "--reload" in rest:
            reload_daemon()
        return 0

    if action == "run":
        base = base_path(base)
        write_atomic(state_dir() / "base-path", base + "\n")
        apply(base, read_rules(rules_path()))
        os.execvp("swaync", ["swaync", "--config", str(config_path())])

    if action == "pick":
        return pick(base_path(base))

    raise SystemExit(f"unknown action: {action}")


def rofi_args():
    args = [
        "rofi",
        "-dmenu",
        "-i",
        "-p",
        "Notification rule",
        "-mesg",
        "Select an application to cycle: On, Silent, Off",
    ]
    theme = os.environ.get("SWAYNC_RULES_THEME")
    if theme:
        args += ["-theme", theme]
    return args


def pick(base):
    rules = read_rules(rules_path())
    names = recent_apps(read_catalogue(catalogue_path()), rules)
    subprocess.run(["swaync-client", "--close-panel"], check=False, timeout=10)
    if not names:
        notify("Notification rules", "No applications have sent notifications yet.")
        return 0

    choice = subprocess.run(
        rofi_args(),
        input="\n".join(format_row(name, rules.get(name, "enabled")) for name in names) + "\n",
        capture_output=True,
        text=True,
    )
    if choice.returncode != 0:
        return 0

    name, state = parse_row(choice.stdout.strip(), rules)
    if not name:
        return 0
    state = next_state(state)
    rules[name] = state
    write_rules(rules_path(), rules)
    apply(base, rules)
    reload_daemon()
    notify(f"Notifications: {name}", f"Set to {STATES[state]}.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError) as error:
        if sys.argv[1:2] == ["record"]:
            raise SystemExit(0)
        notify("Notification rules", str(error))
        raise SystemExit(1)