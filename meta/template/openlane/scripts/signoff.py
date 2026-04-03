#!/usr/bin/env python3
import os
import shutil
import sys

if len(sys.argv) != 3:
    print("Usage: signoff.py <TAG_DIR> <SIGNOFF_DIR>")
    sys.exit(1)
tag_dir = sys.argv[1]
signoff_dir = sys.argv[2]
if not os.path.isdir(tag_dir):
    print(f"Error: TAG directory {tag_dir} not found")
    sys.exit(1)

# 目标后缀（关键）
targets = [
    "magic-drc",
    "klayout-drc",
    "netgen-lvs",
    "openroad-stapostpnr",
    "openroad-checkantennas-1",
    "final"
]

# 列出 TAG 目录下所有子目录
entries = os.listdir(tag_dir)
os.makedirs(signoff_dir, exist_ok=True)
for target in targets:
    matched = None
    for entry in entries:
        full_path = os.path.join(tag_dir, entry)
        if os.path.isdir(full_path) and entry.endswith(target):
            matched = full_path
            break
    if matched is None:
        print(f"Warning: no directory found for *-{target}")
        continue
    dst = os.path.join(signoff_dir, os.path.basename(matched))
    print(f"Copy: {matched} -> {dst}")
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(matched, dst)

print("Signoff collection done.")
