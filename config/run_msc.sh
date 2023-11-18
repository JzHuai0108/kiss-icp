datadir=/media/jhuai/BackupPlus/jhuai/data/mscrad4r
kissicp_ws=/home/jhuai/Documents/lidar/kissicp_ws
script=$kissicp_ws/src/kiss-icp/python/kiss_icp/tools/cmd.py
result_dir=/media/jhuai/BackupPlus/jhuai/results/kissicp/msc

process_rover_python() {
    bagfile=$1
    echo "Processing $bagfile"
    cd $kissicp_ws
    sed -i "/out_dir:/c\out_dir: $result_dir" $kissicp_ws/src/kiss-icp/config/msc_os1_128.yaml
    python3 src/kiss-icp/python/kiss_icp/tools/cmd.py $bagfile --topic=/ouster/points --config=$kissicp_ws/src/kiss-icp/config/msc_os1_128.yaml
}

rover_bags=(
$datadir/RURAL_A0/RURAL_A0.bag
$datadir/RURAL_A1/RURAL_A1.bag
$datadir/RURAL_A2/RURAL_A2.bag
$datadir/RURAL_B0/RURAL_B0.bag
$datadir/RURAL_B1/RURAL_B1.bag
$datadir/RURAL_B2/RURAL_B2.bag
$datadir/RURAL_C0/RURAL_C0.bag
$datadir/RURAL_C1/RURAL_C1.bag
$datadir/RURAL_C2/RURAL_C2.bag
$datadir/RURAL_D0/RURAL_D0.bag
$datadir/RURAL_D1/RURAL_D1.bag
$datadir/RURAL_D2/RURAL_D2.bag
$datadir/RURAL_E0/RURAL_E0.bag
$datadir/RURAL_E1/RURAL_E1.bag
$datadir/RURAL_E2/RURAL_E2.bag
$datadir/RURAL_F0/RURAL_F0.bag
$datadir/RURAL_F1/RURAL_F1.bag
$datadir/RURAL_F2/RURAL_F2.bag
$datadir/URBAN_C0/URBAN_C0.bag
)

counter=0
mkdir -p $result_dir
for bag in ${rover_bags[@]}; do
    process_rover_python $bag
    ((counter++))
    # if [ $counter -gt 0 ]; then
    #     break
    # fi
done
