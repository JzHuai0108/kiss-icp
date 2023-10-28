python3 src/kiss-icp/python/kiss_icp/tools/cmd.py /data/homebrew/handheld/20230921/data2_aligned.bag --topic=/hesai/pandar --config=advanced_hesai32.yaml

roslaunch kiss_icp odometry.launch bagfile:=/data/homebrew/handheld/20230921/data2_aligned.bag topic:=/hesai/pandar max_range:=50 path_est:=~/Documents/lidar/kissicp_ws/results/scan_states.txt