
# Note this script requires a conda env kissicp
kissicp_ws=/media/jhuai/docker/lidarslam/kiss_icp_ws

script=$kissicp_ws/kiss-icp/python/kiss_icp/tools/kisscli.py
result_dir=/home/jhuai/Desktop/temp

process_handheld_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    configyaml=$kissicp_ws/kiss-icp/config/advanced_vlp16_kuangye.yaml
    sed -i "/out_dir:/c\out_dir: $result_dir" $configyaml
    python3 $script $bagfile --topic=/velodyne_points --config=$configyaml -v 
}

# process_handheld_python /media/jhuai/BackupPlus/jhuai/data/kuangye-lidar/2025Mar25/chuanyandong/chuanyandong-fix.bag
# process_handheld_python /home/jhuai/Downloads/2025-07-21-13-26-09.bag
process_handheld_python /home/jhuai/Downloads/chuanyandong_vlp16/chuanyandong_vlp16.bag