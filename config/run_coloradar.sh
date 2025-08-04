datadir=/media/jhuai/BackupPlus/jhuai/data/coloradar/rosbags
kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws
script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/kisscli.py
result_dir=/media/jhuai/BackupPlus/jhuai/results/kissicp/coloradar

process_handheld_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    sed -i "/out_dir:/c\out_dir: $result_dir" $kissicp_ws/src/kiss-icp/config/coloradar_os1_64.yaml
    python3 $script $bagfile --topic=/os1_cloud_node/points --config=$kissicp_ws/src/kiss-icp/config/coloradar_os1_64.yaml
}

handheld_bags=(
$datadir/aspen_run0.bag
$datadir/aspen_run1.bag
$datadir/aspen_run2.bag
$datadir/aspen_run3.bag
$datadir/aspen_run4.bag
$datadir/aspen_run5.bag
$datadir/aspen_run6.bag
$datadir/aspen_run7.bag
$datadir/aspen_run8.bag
$datadir/aspen_run9.bag
$datadir/aspen_run10.bag
$datadir/aspen_run11.bag
$datadir/arpg_lab_run0.bag
$datadir/arpg_lab_run1.bag
$datadir/arpg_lab_run2.bag
$datadir/arpg_lab_run3.bag
$datadir/arpg_lab_run4.bag
$datadir/outdoors_run0.bag
$datadir/outdoors_run1.bag
$datadir/outdoors_run2.bag
$datadir/outdoors_run3.bag
$datadir/outdoors_run4.bag
$datadir/outdoors_run5.bag
$datadir/outdoors_run6.bag
$datadir/outdoors_run7.bag
$datadir/outdoors_run8.bag
$datadir/outdoors_run9.bag
$datadir/longboard_run0.bag
$datadir/longboard_run1.bag
$datadir/longboard_run2.bag
$datadir/longboard_run3.bag
$datadir/longboard_run4.bag
$datadir/longboard_run5.bag
$datadir/longboard_run6.bag
$datadir/longboard_run7.bag
$datadir/edgar_army_run0.bag
$datadir/edgar_army_run1.bag
$datadir/edgar_army_run2.bag
$datadir/edgar_army_run3.bag
$datadir/edgar_army_run4.bag
$datadir/edgar_army_run5.bag
$datadir/ec_hallways_run0.bag
$datadir/ec_hallways_run1.bag
$datadir/ec_hallways_run2.bag
$datadir/ec_hallways_run3.bag
$datadir/ec_hallways_run4.bag
$datadir/edgar_classroom_run0.bag
$datadir/edgar_classroom_run1.bag
$datadir/edgar_classroom_run2.bag
$datadir/edgar_classroom_run3.bag
$datadir/edgar_classroom_run4.bag
$datadir/edgar_classroom_run5.bag
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

