# MIT License
#
# Copyright (c) 2022 Ignacio Vizzo, Tiziano Guadagnino, Benedikt Mersch, Cyrill
# Stachniss.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to mse, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE msE OR OTHER DEALINGS IN THE
# SOFTWARE.
import glob
import os

import numpy as np


class KITTIOdometryDataset:
    def __init__(self, data_dir, sequence: int, *_, **__):
        self.sequence_id = str(int(sequence)).zfill(2)
        self.kitti_sequence_dir = os.path.join(data_dir, "sequences", self.sequence_id)
        self.velodyne_dir = os.path.join(self.kitti_sequence_dir, "velodyne/")

        self.scan_files = sorted(glob.glob(self.velodyne_dir + "*.bin"))
        self.calibration = self.read_calib_file(os.path.join(self.kitti_sequence_dir, "calib.txt"))

        # Load GT Poses (if available)
        if sequence < 11:
            self.poses_fn = os.path.join(data_dir, f"poses/{self.sequence_id}.txt")
            self.gt_poses = self.load_poses(self.poses_fn)

        # Add correction for KITTI datasets, can be easilty removed if unwanted
        from kiss_icp.pybind import kiss_icp_pybind

        self.correct_kitti_scan = lambda frame: np.asarray(
            kiss_icp_pybind._correct_kitti_scan(kiss_icp_pybind._Vector3dVector(frame))
        )

    def __getitem__(self, idx):
        return self.scans(idx)

    def __len__(self):
        return len(self.scan_files)

    def scans(self, idx):
        return self.read_point_cloud(self.scan_files[idx])

    def apply_calibration(self, poses: np.ndarray) -> np.ndarray:
        """Converts from Velodyne to Camera Frame"""
        Tr = np.eye(4, dtype=np.float64)
        Tr[:3, :4] = self.calibration["Tr"].reshape(3, 4)
        return Tr @ poses @ np.linalg.inv(Tr)

    def read_point_cloud(self, scan_file: str):
        points = np.fromfile(scan_file, dtype=np.float32).reshape((-1, 4))[:, :3].astype(np.float64)
        #  points = points[points[:, 2] > -2.9]  # Remove the annoying reflections
        points = self.correct_kitti_scan(points)
        return points

    def load_poses(self, poses_file):
        def _lidar_pose_gt(poses_gt):
            _tr = self.calibration["Tr"].reshape(3, 4)
            tr = np.eye(4, dtype=np.float64)
            tr[:3, :4] = _tr
            left = np.einsum("...ij,...jk->...ik", np.linalg.inv(tr), poses_gt)
            right = np.einsum("...ij,...jk->...ik", left, tr)
            return right

        poses = np.loadtxt(poses_file, delimiter=" ")
        n = poses.shape[0]
        poses = np.concatenate(
            (poses, np.zeros((n, 3), dtype=np.float32), np.ones((n, 1), dtype=np.float32)), axis=1
        )
        poses = poses.reshape((n, 4, 4))  # [N, 4, 4]
        return _lidar_pose_gt(poses)

    def get_frames_timestamps(self) -> np.ndarray:
        timestamps = np.loadtxt(os.path.join(self.kitti_sequence_dir, "times.txt")).reshape(-1, 1)
        return timestamps

    @staticmethod
    def read_calib_file(file_path: str) -> dict:
        calib_dict = {}
        with open(file_path, "r") as calib_file:
            for line in calib_file.readlines():
                tokens = line.split(" ")
                if tokens[0] == "calib_time:":
                    continue
                # Only read with float data
                if len(tokens) > 0:
                    values = [float(token) for token in tokens[1:]]
                    values = np.array(values, dtype=np.float32)

                    # The format in KITTI's file is <key>: <f1> <f2> <f3> ...\n -> Remove the ':'
                    key = tokens[0][:-1]
                    calib_dict[key] = values
        return calib_dict

    def save_as_pcds(self, output_dir: str) -> None:
        """
        Convert all KITTI Velodyne .bin scans in this sequence to PCD files.

        Each .bin is assumed to be float32, shape (N, 4): x, y, z, intensity.
        We write an ASCII PCD with fields: x y z intensity.
        """
        os.makedirs(output_dir, exist_ok=True)

        for s, scan_file in enumerate(self.scan_files):
            # Load raw KITTI scan: (N, 4) -> x, y, z, intensity
            raw = np.fromfile(scan_file, dtype=np.float32).reshape(-1, 4)
            points = raw[:, :3]
            intensities = raw[:, 3:4]

            # If you want corrected scans, uncomment the next line:
            points = self.correct_kitti_scan(points)

            cloud = np.hstack((points, intensities)).astype(np.float32)
            n_points = cloud.shape[0]

            # Build output filename: 000000.bin -> 000000.pcd
            base_name = os.path.splitext(os.path.basename(scan_file))[0]
            out_path = os.path.join(output_dir, base_name + ".pcd")

            # Write ASCII PCD (simple & readable)
            header = (
                "# .PCD v0.7 - Point Cloud Data file format\n"
                "VERSION 0.7\n"
                "FIELDS x y z intensity\n"
                "SIZE 4 4 4 4\n"
                "TYPE F F F F\n"
                "COUNT 1 1 1 1\n"
                f"WIDTH {n_points}\n"
                "HEIGHT 1\n"
                "VIEWPOINT 0 0 0 1 0 0 0\n"
                f"POINTS {n_points}\n"
                "DATA ascii\n"
            )

            with open(out_path, "w") as f:
                f.write(header)
                for p in cloud:
                    f.write(f"{p[0]} {p[1]} {p[2]} {p[3]}\n")
            if s % 100 == 0:
                print(f"Saved PCD: {out_path}")


def main():
    import os
    import sys

    if len(sys.argv) < 3 or len(sys.argv) > 4:
        script_name = os.path.basename(sys.argv[0])
        print(f"Usage: {script_name} <kitti_root> <output_dir> [seq]")
        print(f"Example (all seqs): {script_name} /path/to/KITTI/odometry /tmp/kitti_pcds")
        print(f"Example (one seq) : {script_name} /path/to/KITTI/odometry /tmp/kitti_pcds 0")
        sys.exit(1)

    _, kitti_root, output_root = sys.argv[:3]

    # Determine which sequences to process
    if len(sys.argv) == 4:
        # Single sequence given on command line
        seq_id = int(sys.argv[3])
        sequences = [seq_id]
    else:
        # All immediate subfolders under kitti_root/sequences (e.g. "00", "01", ...)
        sequences_root = os.path.join(kitti_root, "sequences")
        if not os.path.isdir(sequences_root):
            print(f"[ERROR] Not a valid KITTI root (missing 'sequences' dir): {kitti_root}")
            sys.exit(1)

        sequences = []
        for d in sorted(os.listdir(sequences_root)):
            full = os.path.join(sequences_root, d)
            if os.path.isdir(full):
                try:
                    sequences.append(int(d))  # store as int, e.g. "00" -> 0
                except ValueError:
                    print(f"[WARN] Skipping non-numeric sequence folder: {d}")

        if not sequences:
            print(f"[WARN] No sequences found under: {sequences_root}")
            sys.exit(0)

    for seq in sequences:
        print(f"[INFO] Converting sequence {seq} to PCDs...")
        dataset = KITTIOdometryDataset(kitti_root, seq)
        seq_str = f"{seq:02d}"
        seq_output_dir = os.path.join(output_root, seq_str)
        dataset.save_as_pcds(seq_output_dir)

    print("[INFO] All sequences converted.")


if __name__ == "__main__":
    main()
