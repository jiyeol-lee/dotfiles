#!/usr/bin/env python3
import re, shutil, subprocess, sys

def run(cmd):
    # print("+", " ".join(cmd))
    subprocess.run(cmd, check=True)

def list_blocks():
    out = subprocess.run(["sudo", "libinput", "list-devices"],
                         capture_output=True, text=True, check=True).stdout
    return re.split(r"\n\s*\n", out)

def find_touchpads():
    found = []
    for b in list_blocks():
        m = re.search(r"^\s*Device:\s*(.+?)\s*$", b, re.M)
        if not m or "touchpad" not in m.group(1).lower():
            continue
        name = m.group(1).strip()
        im = re.search(r"^\s*Id:\s*(\S+)", b, re.M)
        id_str = im.group(1) if im else ""
        found.append((name, id_str, b))
    return found

def parse_ids(name, id_str):
    parts = id_str.split(":")
    if len(parts) >= 3 and len(parts[1]) == 4 and len(parts[2]) == 4:
        return parts[1], parts[2]
    raise SystemExit(f"cannot parse vendor:product from Id='{id_str}' Name='{name}'")

def parse_pairs(args):
    pairs = []
    i = 0
    while i < len(args):
        if "=" in args[i]:
            k, v = args[i].split("=", 1)
            pairs.append((k, v)); i += 1
        else:
            if i + 1 >= len(args):
                raise SystemExit(f"missing value for {args[i]}")
            pairs.append((args[i], args[i+1])); i += 2
    return pairs

def main():
    tps = find_touchpads()
    if not tps:
        raise SystemExit("no touchpad found")
    name, id_str, _ = tps[0]  # single touchpad
    v_hex, p_hex = parse_ids(name, id_str)
    v_dec, p_dec = str(int(v_hex, 16)), str(int(p_hex, 16))
    # print(f"Device: {name}\nId: {id_str} -> {v_hex}/{p_hex} -> {v_dec}/{p_dec}")

    for key, val in parse_pairs(sys.argv[1:]):
        run(["kwriteconfig6", "--file", "kcminputrc",
             "--group", "Libinput", "--group", v_dec,
             "--group", p_dec, "--group", name,
             "--key", key, val])

if __name__ == "__main__":
    main()
