"""Choose an available iPhone for the pinned Xcode 16.4 / iOS 18.5 runtime."""
import json
import sys


def select_device(inventory: dict) -> str:
    for runtime, devices in inventory.get("devices", {}).items():
        if not runtime.endswith("iOS-18-5"):
            continue
        for device in devices:
            if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
                return device["udid"]
    raise RuntimeError("No available iOS 18.5 iPhone simulator for Xcode 16.4. Inspect build/devices.json; do not skip tests.")


if __name__ == "__main__":
    with open(sys.argv[1], encoding="utf-8") as file:
        print(select_device(json.load(file)))
