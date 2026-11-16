import math
import subprocess
import sys


MODELS = {"lg": "MP59G", "pixio": "PX277h/PX276h"}


def main():
    display, action, *args = sys.argv[1:]
    model = MODELS[display]
    command = ["ddcutil", "--model", model, "--terse"]
    result = subprocess.run(
        [*command, "getvcp", "10"], capture_output=True, text=True, check=True, timeout=30
    )
    fields = result.stdout.strip().split()
    if len(fields) != 5 or fields[:3] != ["VCP", "10", "C"]:
        raise ValueError("Unexpected brightness response")
    current, maximum = map(int, fields[3:])
    if maximum <= 0 or not 0 <= current <= maximum:
        raise ValueError("Invalid brightness response")
    if action == "get":
        print(round(current * 100 / maximum), flush=True)
    elif action == "set":
        value = float(args[0])
        if not math.isfinite(value) or not 0 <= value <= 100:
            raise ValueError("Invalid brightness value")
        subprocess.run(
            [*command, "setvcp", "10", str(round(value * maximum / 100))],
            capture_output=True, text=True, check=True, timeout=30,
        )
    else:
        raise ValueError("Unknown action")


if __name__ == "__main__":
    try:
        main()
    except (KeyError, ValueError, IndexError, OSError, subprocess.SubprocessError) as error:
        detail = error.stderr.strip() if isinstance(error, subprocess.CalledProcessError) and error.stderr else str(error)
        subprocess.run(["notify-send", "Display brightness", detail], check=False)
        if len(sys.argv) > 2 and sys.argv[2] == "get":
            print("nan", flush=True)
        sys.exit(1)
