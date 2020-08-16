output_file_format="tcp";
iteration_float=$(echo "5.0*2.0*2.0*2.0" | bc)
 
minNodes=30
maxNodes=60
 
minFlows=10
maxFlows=50
 
minPackets=100
maxPackets=500
 
minSpeed=5
maxSpeed=25
 
 
iteration=$(printf %.0f $iteration_float);
 
node=$minNodes
 
while [ $node -le $maxNodes ]
do
echo "total iteration: with $node nodes"
###############################START A ROUND
l=0;thr=0.0;del=0.0;s_packet=0.0;r_packet=0.0;d_packet=0.0;del_ratio=0.0;
dr_ratio=0.0;time=0.0;t_energy=0.0;energy_bit=0.0;energy_byte=0.0;energy_packet=0.0;total_retransmit=0.0;
itNo=0
 
flowNo=$minFlows
while [ $flowNo -le $maxFlows ]
do
    echo "                             flow No: $flowNo"
 
packetNo=$minPackets
while [ $packetNo -le $maxPackets ]
do
#################START AN ITERATION with varied packet/s
echo "                             EXECUTING with $packetNo packets/s"
 
 

 
ns wired.tcl $node $flowNo $packetNo 
echo "SIMULATION COMPLETE. BUILDING STAT......"
#awk -f rule_th_del_enr_tcp.awk 802_11_grid_tcp_with_energy_random_traffic.tr > math_model1.out
awk -f wired.awk staticout.tr > wired.out
itNo=$(($itNo+1))
 
while read val
do
#   l=$(($l+$inc))
    l=$(($l+1))
    dir="/home/ubuntu/ns2_data/iTCP/"
    #dir=""
    under="_"
    all="all"
    output_file="$output_file_format$under$node$under$itNo$under$all.out"
   
#   echo -ne "Throughput:          $thr " > $output_file
 
    if [ "$l" == "1" ]; then
        thr=$(echo "scale=5; $thr+$val/$iteration_float" | bc)
        echo -ne "throughput: $val \n" >> $output_file
    elif [ "$l" == "2" ]; then
        del=$(echo "scale=5; $del+$val/$iteration_float" | bc)
        echo -ne "delay: $val \n" >> $output_file
    elif [ "$l" == "3" ]; then
        s_packet=$(echo "scale=5; $s_packet+$val/$iteration_float" | bc)
        echo -ne "send packet: $val \n" >> $output_file
    elif [ "$l" == "4" ]; then
        r_packet=$(echo "scale=5; $r_packet+$val/$iteration_float" | bc)
        echo -ne "received packet: $val \n" >> $output_file
    elif [ "$l" == "5" ]; then
        d_packet=$(echo "scale=5; $d_packet+$val/$iteration_float" | bc)
        echo -ne "drop packet: $val \n" >> $output_file
    elif [ "$l" == "6" ]; then
        del_ratio=$(echo "scale=5; $del_ratio+$val/$iteration_float" | bc)
        echo -ne "delivery ratio: $val \n" >> $output_file
    elif [ "$l" == "7" ]; then
        dr_ratio=$(echo "scale=5; $dr_ratio+$val/$iteration_float" | bc)
        echo -ne "drop ratio: $val \n" >> $output_file
    elif [ "$l" == "8" ]; then
        time=$(echo "scale=5; $time+$val/$iteration_float" | bc)
        echo -ne "time: $val \n" >> $output_file
    else
	echo -ne "per node throughput: $val \n" >> $output_file
    
    fi
 
 
    echo "$val"
done < wired.out
 

l=0

 
packetNo=$(($packetNo+100))
#################END AN ITERATION with varied speed
done
 
flowNo=$(($flowNo+10))
#################END AN ITERATION with varied number of flows
done
 
#dir=""
under="_"
output_file="$output_file_format$under$node$under$node.out"
output_file1="thXY.out"
output_file2="delayXY.out"
output_file3="delXY.out"
output_file4="drpXY.out"

 
echo -ne "$node $thr \n" >> $output_file1
echo -ne "$node $del \n" >> $output_file2
echo -ne "$Sent packets: $s_packet \n" >> $output_file
echo -ne "Receievd packets: $r_packet \n" >> $output_file
echo -ne "Dropped packets: $d_packet \n" >> $output_file
echo -ne "$node $del_ratio \n" >> $output_file3
echo -ne "$node $dr_ratio \n" >> $output_file4
echo -ne "Total time:  $time \n" >> $output_file


 
node=$(($node+20))
#######################################END A ROUND
done
 
xgraph thXY.out -x "Number of nodes" -y "Throughput"
xgraph delayXY.out -x "Number of nodes" -y "Delay"
xgraph delXY.out -x "Number of nodes" -y "DeliveryRate"
xgraph drpXY.out -x "Number of nodes" -y "DropRate"

 
# rm -rf *.out
# rm -rf *.tr
# rm -rf *.nam
