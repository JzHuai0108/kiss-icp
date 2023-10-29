datadir=/media/jhuai/SeagateData/jhuai/data/homebrew
kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws
script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/cmd.py
result_dir=/media/jhuai/SeagateData/jhuai/results/kissicp

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


handheld_bags=(
$datadir/handheld/20230921/data2_aligned.bag
$datadir/handheld/20230920/data2_aligned.bag
$datadir/handheld/20230921/data3_aligned.bag
$datadir/handheld/20230921/data4_aligned.bag
$datadir/handheld/20230921/data5_aligned.bag
$datadir/handheld/20231007/data5_aligned.bag
$datadir/handheld/20231019/data1_aligned.bag
$datadir/handheld/20231019/data2_aligned.bag
$datadir/handheld/20231025/data1_aligned.bag
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

for bag in ${handheld_bags[@]}; do
    process_handheld_python $bag
    # dn=$(dirname $bag)
    # bagdn=$(basename $dn)
    # fn=$(basename $bag)
    # fnnoext="${fn%%.*}"
    # path_est=$result_dir/$bagdn/"$fnnoext"_scan_states.txt
    # process_ros1 $bag /hesai/pandar 50 $path_est
done

for bag in ${rover_bags[@]}; do
    process_rover_python $bag
done

