
# Note this script requires a conda env kissicp
kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws

script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/cmd.py
result_dir=/home/jhuai/Desktop/temp

process_handheld_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    configyaml=$kissicp_ws/src/kiss-icp/config/advanced_vlp16_kuangye.yaml
    sed -i "/out_dir:/c\out_dir: $result_dir" $configyaml
    python3 $script $bagfile --topic=/velodyne_points --config=$configyaml
}

process_handheld_python /media/jhuai/BackupPlus/jhuai/data/kuangye-lidar/2025Mar25/chuanyandong/chuanyandong-fix.bag
