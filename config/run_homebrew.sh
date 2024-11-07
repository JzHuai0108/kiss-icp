datadir=/media/jhuai/BackupPlus/jhuai/data/homebrew
datadir=/media/jhuai/MyBookDuo/jhuai/data/homebrew/zongmu

kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws

script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/cmd.py
result_dir=/media/jhuai/BackupPlus/jhuai/results/kissicp/homebrew
result_dir=/media/jhuai/SeagateData/jhuai/results/kissicp/
result_dir=/media/jhuai/MyBookDuo/jhuai/results/kissicp/

process_handheld_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    sed -i "/out_dir:/c\out_dir: $result_dir" $kissicp_ws/src/kiss-icp/config/advanced_hesai32.yaml
    python3 $script $bagfile --topic=/hesai/pandar --config=$kissicp_ws/src/kiss-icp/config/advanced_hesai32.yaml
}

# Running with ros is not preferred as the recorded poses miss many frames.
process_ros1() {
    bagfile=$1
    topic=$2
    max_range=$3
    path_est=$4
    echo "Processing $bagfile on topic $topic with max range $max_range while saving to $path_est"
    cd $kissicp_ws
    source devel/setup.bash
    roslaunch kiss_icp odometry.launch bagfile:=$bagfile topic:=$topic max_range:=$max_range path_est:=$path_est closeatend:=true
}

process_rover_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    sed -i "/out_dir:/c\out_dir: $result_dir" $kissicp_ws/src/kiss-icp/config/advanced_vlp16.yaml
    python3 src/kiss-icp/python/kiss_icp/tools/cmd.py $bagfile --topic=/velodyne_points --config=$kissicp_ws/src/kiss-icp/config/advanced_vlp16.yaml
}

handheld_bags0=(
$datadir/handheld/20230920/data2_aligned.bag
$datadir/handheld/20230921/data2_aligned.bag
$datadir/handheld/20230921/data3_aligned.bag
$datadir/handheld/20230921/data4_aligned.bag
$datadir/handheld/20230921/data5_aligned.bag
$datadir/handheld/20231007/data5_aligned.bag
$datadir/handheld/20231019/data1_aligned.bag
$datadir/handheld/20231019/data2_aligned.bag
$datadir/handheld/20231025/data1_aligned.bag
)

handheld_bags=(
$datadir/handheld/20231105/data1_aligned.bag
$datadir/handheld/20231105/data2_aligned.bag
$datadir/handheld/20231105/data3_aligned.bag
$datadir/handheld/20231105/data4_aligned.bag
$datadir/handheld/20231105/data5_aligned.bag
$datadir/handheld/20231105/data6_aligned.bag
$datadir/handheld/20231105/data7_aligned.bag
$datadir/handheld/20231105_aft/data1_aligned.bag
$datadir/handheld/20231105_aft/data2_aligned.bag
$datadir/handheld/20231105_aft/data3_aligned.bag
$datadir/handheld/20231105_aft/data4_aligned.bag
$datadir/handheld/20231105_aft/data5_aligned.bag
$datadir/handheld/20231105_aft/data6_aligned.bag
$datadir/handheld/20231109/data1_aligned.bag
$datadir/handheld/20231109/data2_aligned.bag
$datadir/handheld/20231109/data3_aligned.bag
$datadir/handheld/20231109/data4_aligned.bag
)

handheld_bags=(
$datadir/handheld-obsolete/20230920/data1_aligned.bag
$datadir/ebike-obsolete/20231007/data1_aligned.bag
$datadir/ebike-obsolete/20231007/data2_aligned.bag
$datadir/ebike-obsolete/20231007/data3_aligned.bag
$datadir/ebike-obsolete/20231007/data4_aligned.bag
$datadir/ebike-obsolete/20231025/data2_aligned.bag
)

handheld_bags=($datadir/20240123/data1_aligned.bag
$datadir/20240123/data2_aligned.bag
$datadir/20240123/data3_aligned.bag
$datadir/20240131/data1_aligned.bag
$datadir/20240131/data2_aligned.bag
$datadir/20240131/data3_aligned.bag
$datadir/20240131/data4_aligned.bag
$datadir/20240131/data5_aligned.bag
$datadir/20240131/data6_aligned.bag
)

rover_bags=(
$datadir/mycar_nav/20220929/lidar4_aligned.bag
$datadir/mycar_nav/20221019/lidar3_aligned.bag
$datadir/mycar_nav/20221019/lidar4_aligned.bag
$datadir/mycar_nav/20221021/lidar3_aligned.bag
$datadir/mycar_nav/20221021/lidar4_aligned.bag
$datadir/mycar_nav/20230814/lidar6_aligned.bag
$datadir/mycar_nav/20230814/lidar7_aligned.bag
)

datadir=/media/pi/BackupPlus/jhuai/data/homebrew/zongmu
handheld_bags=(
    $datadir/20231201/data2_aligned.bag
    $datadir/20231201/data3_aligned.bag
    $datadir/20231208/data1_aligned.bag
    $datadir/20231208/data2_aligned.bag
    $datadir/20231208/data3_aligned.bag
    $datadir/20231208/data4_aligned.bag
    $datadir/20231208/data5_aligned.bag
    $datadir/20231213/data1_aligned.bag
    $datadir/20231213/data2_aligned.bag
    $datadir/20231213/data3_aligned.bag
    $datadir/20231213/data4_aligned.bag
    $datadir/20231213/data5_aligned.bag
)

counter=0
mkdir -p $result_dir
for bag in ${handheld_bags[@]}; do
    process_handheld_python $bag
    ((counter++))
    # if [ $counter -gt 0 ]; then
    #     break
    # fi
done

datadir="/media/pi/My_Book/jhuai/data/zongmu"
handheld_bags=(
    $datadir/20240113/data1_aligned.bag
    $datadir/20240113/data2_aligned.bag
    $datadir/20240113/data3_aligned.bag
    $datadir/20240113/data4_aligned.bag
    $datadir/20240113/data5_aligned.bag
    $datadir/20240115/data1_aligned.bag
    $datadir/20240115/data2_aligned.bag
    $datadir/20240115/data3_aligned.bag
    $datadir/20240115/data4_aligned.bag
    $datadir/20240116/data2_aligned.bag
    $datadir/20240116/data3_aligned.bag
    $datadir/20240116/data4_aligned.bag
    $datadir/20240116/data5_aligned.bag
    $datadir/20240116_eve/data1_aligned.bag
    $datadir/20240116_eve/data2_aligned.bag
    $datadir/20240116_eve/data3_aligned.bag
    $datadir/20240116_eve/data4_aligned.bag
    $datadir/20240116_eve/data5_aligned.bag
)

counter=0
mkdir -p $result_dir
for bag in ${handheld_bags[@]}; do
    process_handheld_python $bag
    ((counter++))
    # if [ $counter -gt 0 ]; then
    #     break
    # fi
done
