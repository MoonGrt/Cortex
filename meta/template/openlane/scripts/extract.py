#!/usr/bin/env python3
import json, os, shutil, sys, glob

if len(sys.argv) != 3:
    print("Usage: copy.py <TAG_DIR> <DIR>")
    sys.exit(1)

tag_dir = sys.argv[1]
des_dir = sys.argv[2]
libs_path = os.path.join(des_dir, "libs")
json_path = os.path.join(tag_dir, "resolved.json")
layout_net_path = os.path.join(des_dir, "nets", "layout", 'nl')
synth_net_path = os.path.join(des_dir, "nets", "synth", 'nl')

# ---------- Step 1: 处理 CELL_VERILOG_MODELS ----------
if not os.path.isfile(json_path):
    print(f"Error: {json_path} not found")
    sys.exit(1)
with open(json_path, "r") as f:
    data = json.load(f)
if "CELL_VERILOG_MODELS" not in data:
    print("Error: CELL_VERILOG_MODELS not found in JSON")
    sys.exit(1)
files = data["CELL_VERILOG_MODELS"]
if isinstance(files, str):
    files = files.split()
os.makedirs(libs_path, exist_ok=True)
for model in files:
    if not os.path.isfile(model):
        print(f"Warning: {model} not found, skip")
        continue
    print(f"Copy model: {model} -> {libs_path}")
    shutil.copy(model, libs_path)

# ---------- Step 2: 处理 *-yosys-synthesis ----------
print("Searching for *-yosys-synthesis directories...")
synth_dirs = glob.glob(os.path.join(tag_dir, "*-yosys-synthesis"))
if not synth_dirs:
    print("Warning: no *-yosys-synthesis dir found")
else:
    os.makedirs(synth_net_path, exist_ok=True)
    for synth_dir in synth_dirs:
        print(f"Processing: {synth_dir}")
        nl_files = glob.glob(os.path.join(synth_dir, "*.nl.v"))
        if not nl_files:
            print(f"Warning: no *.nl.v in {synth_dir}")
            continue
        for f in nl_files:
            if not os.path.isfile(f):
                continue
            print(f"Copy synth netlist: {f} -> {synth_net_path}")
            shutil.copy(f, synth_net_path)

# ---------- Step 3: 复制 final 目录（重构版） ----------
final_dir = os.path.join(tag_dir, "final")
layout_base_path = os.path.join(des_dir, "nets", "layout")
mapping = {
    "nl": "nl",
    "sdf": "sdf",
}
for sub, sub_dst_name in mapping.items():
    src = os.path.join(final_dir, sub)
    # 构造目标路径：nets/layout/nl 或 nets/layout/sdf
    target_path = os.path.join(layout_base_path, sub_dst_name)
    if not os.path.isdir(src):
        print(f"Warning: {src} not found, skip")
        continue
    print(f"Copy dir: {src} -> {target_path}")
    # 如果目标子文件夹已存在，先删除
    if os.path.exists(target_path):
        shutil.rmtree(target_path)
    # 执行拷贝，这会在 layout 目录下创建相应的子目录
    shutil.copytree(src, target_path)

print("All done.")
