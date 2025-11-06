
#!/usr/bin/env python3
import os
import sys

import kiss_icp
import matplotlib.pyplot as plt
import numpy as np
from evo.tools import plot
from kiss_icp.datasets import dataset_factory
from kiss_icp.pipeline import OdometryPipeline

from kiss_icp_eval import run_sequence
from kiss_icp_eval import print_metrics_table
from kiss_icp_eval import plot_trajectories

DEFAULT_KITTI_ROOT = "/media/jhuai/BackupPlus/jhuai/data/KITTI/semantic/dataset"
DEFAULT_KITTI_CONFIG = "/home/jhuai/Documents/lidar/kissicp_ws/src/kiss-icp/config/advanced_kitti.yaml"
DEFAULT_OUTPUT_DIR   = "/media/jhuai/BackupPlus/jhuai/kitti_results/kissicp"


def patch_out_dir_in_config(config_path: str, out_dir: str) -> None:
    """Replace the line `out_dir: "results"` in the config by `out_dir: "<out_dir>"`."""
    if not os.path.isfile(config_path):
        print(f"[WARN] Config file not found: {config_path}")
        return

    with open(config_path, "r") as f:
        lines = f.readlines()

    with open(config_path, "w") as f:
        for line in lines:
            if line.lstrip().startswith("out_dir:"):
                f.write(f'out_dir: "{out_dir}"\n')
            else:
                f.write(line)


script_name = os.path.basename(sys.argv[0])

if len(sys.argv) < 2:
    print(f"Usage: {script_name} [kitti_root_path] [kitti_config.yaml] [output_dir]")
    print(f'Example: {script_name} "{DEFAULT_KITTI_ROOT}" "{DEFAULT_KITTI_CONFIG}" "{DEFAULT_OUTPUT_DIR}"')
    print("No argument given, using defaults.")
    kitti_root  = DEFAULT_KITTI_ROOT
    kitti_config = DEFAULT_KITTI_CONFIG
    output_dir  = DEFAULT_OUTPUT_DIR
else:
    kitti_root   = sys.argv[1] if len(sys.argv) >= 2 else DEFAULT_KITTI_ROOT
    kitti_config = sys.argv[2] if len(sys.argv) >= 3 else DEFAULT_KITTI_CONFIG
    output_dir   = sys.argv[3] if len(sys.argv) >= 4 else DEFAULT_OUTPUT_DIR

os.makedirs(output_dir, exist_ok=True)
patch_out_dir_in_config(kitti_config, output_dir)

print(f"Reading datasets from      : {kitti_root}")
print(f"Using KITTI config YAML    : {kitti_config}")
print(f"Writing results to out_dir : {output_dir}")

def kitti_sequence(sequence: int):
    return OdometryPipeline(
        dataset=dataset_factory(
            dataloader="kitti",
            data_dir=kitti_root,
            sequence=sequence,
        ), config=kitti_config
    )

results = {}
num_seqs = 22
for sequence in range(0, num_seqs):
    run_sequence(kitti_sequence, sequence=sequence, results=results)

if num_seqs < 12:
    print_metrics_table(results)

results["out_dir"] = os.path.join(output_dir, 'latest')
plot_trajectories(results)
