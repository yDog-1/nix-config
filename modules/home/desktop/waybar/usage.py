import html
import json
import os
import subprocess
import sys
import time


def cpu_times():
    with open('/proc/stat') as stat:
        fields = [int(value) for value in stat.readline().split()[1:]]
    return sum(fields[:8]), fields[3] + fields[4]


def cpu_percent():
    total1, idle1 = cpu_times()
    time.sleep(0.2)
    total2, idle2 = cpu_times()
    delta = total2 - total1
    return round(100 * (1 - (idle2 - idle1) / delta)) if delta else 0


def memory_percent():
    with open('/proc/meminfo') as meminfo:
        entries = {line.split(':', 1)[0]: int(line.split()[1]) for line in meminfo if ':' in line}
    return round(100 * (entries['MemTotal'] - entries['MemAvailable']) / entries['MemTotal'])


def gpu_stats():
    try:
        result = subprocess.run(
            ['/run/current-system/sw/bin/nvidia-smi', '--query-gpu=utilization.gpu,memory.used,memory.total', '--format=csv,noheader,nounits'],
            capture_output=True, text=True, check=True, timeout=3,
        )
        rows = [[int(value.strip()) for value in line.split(',')] for line in result.stdout.splitlines()]
        if not rows or any(len(row) != 3 or row[2] <= 0 for row in rows):
            return None
        return round(sum(row[0] for row in rows) / len(rows)), round(100 * sum(row[1] for row in rows) / sum(row[2] for row in rows))
    except (OSError, ValueError, subprocess.SubprocessError):
        return None


def disk_percent(path):
    stat = os.statvfs(path)
    used = stat.f_blocks - stat.f_bfree
    available = used + stat.f_bavail
    return round(100 * used / available) if available else 0


def disk_mounts():
    try:
        output = subprocess.run(
            ['findmnt', '--real', '--list', '--json', '--output', 'SOURCE,TARGET'],
            capture_output=True, text=True, check=True, timeout=3,
        )
        return json.loads(output.stdout)['filesystems']
    except (OSError, KeyError, ValueError, subprocess.SubprocessError):
        return None


def output(kind):
    if kind == 'cpu':
        usage = cpu_percent()
        gpu = gpu_stats()
        tooltip = f'CPU: {usage}%\nGPU: {str(gpu[0]) + "%" if gpu else "取得不可"}'
    elif kind == 'memory':
        usage = memory_percent()
        gpu = gpu_stats()
        tooltip = f'RAM: {usage}%\nVRAM: {str(gpu[1]) + "%" if gpu else "取得不可"}'
    else:
        usage = disk_percent('/')
        mounts = disk_mounts()
        lines = []
        for mount in mounts or []:
            try:
                percent = f'{disk_percent(mount["target"])}%'
            except OSError:
                percent = '取得不可'
            lines.append(f'{mount["source"]} ({mount["target"]}): {percent}')
        tooltip = '\n'.join(lines) if mounts is not None else 'マウント情報を取得不可'
    return {'text': f'{usage}%', 'tooltip': html.escape(tooltip)}


if __name__ == '__main__':
    print(json.dumps(output(sys.argv[1]), ensure_ascii=False))
