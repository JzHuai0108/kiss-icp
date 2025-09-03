
# Note this script requires a conda env kissicp
kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws

script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/kisscli.py
result_dir=/home/jhuai/Desktop/temp

process_handheld_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    configyaml=$kissicp_ws/src/kiss-icp/config/advanced_hovermap_st.yaml
    sed -i "/out_dir:/c\out_dir: $result_dir" $configyaml
    python3 $script $bagfile --topic=/velodyne_points --config=$configyaml
}

process_handheld_python /media/jhuai/BackupPlus/jhuai/data/kuangye-lidar/hovermap-sample/hovermap数据20241126/手持hovermap静止后拿走-室内/Intermediate/1125_2024-11-26-01-28-09_0/aligned.bag

# process_handheld_python /media/jhuai/BackupPlus/jhuai/data/kuangye-lidar/hovermap-sample/sample1/Yfkq_01/Intermediate/Yfkq_2021-06-23-01-28-35_aligned.bag

# process_handheld_python  /media/jhuai/BackupPlus/jhuai/data/kuangye-lidar/hovermap-sample/江西武铜斜坡道445-433hovermap数据/intermediate/0829445e8e93_2024-08-29-02-46-20_aligned.bag