import os
import shutil
import glob

input_root = "/media/jhuai/BackupPlus/jhuai/kitti_results/kissicp"
output_root = os.path.join(input_root, "submission")

os.makedirs(output_root, exist_ok=True)

# Iterate through all subfolders under input_root
for subdir in sorted(os.listdir(input_root)):
    subpath = os.path.join(input_root, subdir)
    if not os.path.isdir(subpath):
        continue

    # Find files like 00_poses_kitti.txt up to 21_poses_kitti.txt
    for seq in range(22):
        seq_name = f"{seq:02d}_poses_kitti.txt"
        src = os.path.join(subpath, seq_name)
        if os.path.exists(src):
            dst = os.path.join(output_root, f"{seq:02d}.txt")
            shutil.copy2(src, dst)
            print(f"Copied {src} -> {dst}")

print("✅ Done copying all available sequence files.")
