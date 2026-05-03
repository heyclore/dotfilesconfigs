#!/usr/bin/env python3
import time
import os

# Check for BAT0 or BATT automatically
BAT_PATH = "/sys/class/power_supply/BAT0/capacity"
if not os.path.exists(BAT_PATH):
    BAT_PATH = "/sys/class/power_supply/BATT/capacity"

LOG_FILE = "benchmark_log.txt"

def get_battery():
    if os.path.exists(BAT_PATH):
        with open(BAT_PATH, 'r') as f:
            return f.read().strip()
    return "0"

def get_cpu_ghz():
    try:
        with open("/proc/cpuinfo", "r") as f:
            lines = f.readlines()
        freqs = [float(line.split(":")[1]) for line in lines if "cpu MHz" in line]
        if freqs:
            return (sum(freqs) / len(freqs)) / 1000
    except Exception:
        pass
    return 0.0

def get_ram_gb():
    meminfo = {}
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                parts = line.split()
                if len(parts) >= 2:
                    meminfo[parts[0].replace(":", "")] = int(parts[1])
        used_kb = meminfo["MemTotal"] - meminfo.get("MemAvailable", meminfo["MemFree"])
        return used_kb / (1024 * 1024)
    except Exception:
        return 0.0

def get_gpu_usage():
    try:
        with open("/sys/class/drm/card1/device/gpu_busy_percent", "r") as f:
            return float(f.read().strip())
    except Exception:
        return 0.0

def get_power_watts():
    try:
        with open("/sys/class/power_supply/BATT/power_now", "r") as f:
            return float(f.read().strip()) / 1_000_000
    except Exception:
        return 0.0

# Open file with line buffering (buffering=1) so it writes every line immediately
with open(LOG_FILE, "a", buffering=1) as log:
    while True:
        ts = int(time.time())
        batt = get_battery()
        cpu = get_cpu_ghz()
        mem = get_ram_gb()
        gpu = get_gpu_usage()
        power = get_power_watts()

        #log_entry = f"TIME: {ts}, BATTERY: {batt}%, CPU: {cpu:.2f}GHz, RAM: {mem:.2f}GB"
        log_entry = (
                f"TIME: {ts}, BATTERY: {batt}%, "
                f"CPU: {cpu:.2f}GHz, RAM: {mem:.2f}GB, "
                f"GPU: {gpu:.0f}%, "
                f"POWER: {power:.2f}W"
                )
        print(log_entry)
        log.write(log_entry + '\n')

        time.sleep(30)
