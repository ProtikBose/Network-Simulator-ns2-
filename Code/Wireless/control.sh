
#INPUT: output file AND number of iterations
output_file_format="tcp";
iteration_float=$(echo "5.0*2.0*2.0*2.0" | bc)

minNodes=20
maxNodes=100

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


speed=$minSpeed
while [ $speed -le $maxSpeed ]
do
#################START AN ITERATION with varied speeds
echo "                             EXECUTING with $speed speed"

ns wirelessMobile.tcl $node $flowNo $packetNo $speed
echo "SIMULATION COMPLETE. BUILDING STAT......"
#awk -f rule_th_del_enr_tcp.awk 802_11_grid_tcp_with_energy_random_traffic.tr > math_model1.out
awk -f mobileAwk.awk mobileout.tr > udp_wireless.out
itNo=$(($itNo+1))

while read val
do
#	l=$(($l+$inc))
	l=$(($l+1))
	dir="/home/ubuntu/ns2_data/iTCP/"
	#dir=""
	under="_"
	all="all"
	output_file="$output_file_format$under$node$under$itNo$under$all.out"
	
#	echo -ne "Throughput:          $thr " > $output_file

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
	elif [ "$l" == "9" ]; then
		t_energy=$(echo "scale=5; $t_energy+$val/$iteration_float" | bc)
		echo -ne "total_energy: $val \n" >> $output_file
	elif [ "$l" == "10" ]; then
		energy_bit=$(echo "scale=5; $energy_bit+$val/$iteration_float" | bc)
		echo -ne "energy_per_bit: $val \n" >> $output_file
	elif [ "$l" == "11" ]; then
		energy_byte=$(echo "scale=5; $energy_byte+$val/$iteration_float" | bc)
		echo -ne "energy_per_byte: $val \n" >> $output_file
	elif [ "$l" == "12" ]; then
		energy_packet=$(echo "scale=5; $energy_packet+$val/$iteration_float" | bc)
		echo -ne "energy_per_packet: $val \n" >> $output_file
	elif [ "$l" == "13" ]; then
		total_retransmit=$(echo "scale=5; $total_retransmit+$val/$iteration_float" | bc)
		echo -ne "total_retrnsmit: $val \n" >> $output_file
	else
		echo -ne "per node throughput: $val\n">>$output_file	
	fi


	echo "$val"
done < udp_wireless.out

speed=$(($speed+5))
l=0
#################END AN ITERATION with varied speed
done

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
output_file5="engXY.out"

echo -ne "$node $thr \n" >> $output_file1
echo -ne "$node $del \n" >> $output_file2
echo -ne "$Sent packets: $s_packet \n" >> $output_file
echo -ne "Receievd packets: $r_packet \n" >> $output_file
echo -ne "Dropped packets: $d_packet \n" >> $output_file
echo -ne "$node $del_ratio \n" >> $output_file3
echo -ne "$node $dr_ratio \n" >> $output_file4
echo -ne "Total time:  $time \n" >> $output_file
echo -ne "$node $t_energy \n" >> $output_file5
echo -ne "Average Energy per bit: $energy_bit \n" >> $output_file
echo -ne "Average Energy per byte: $energy_byte \n" >> $output_file
echo -ne "Average energy per packet: $energy_packet \n" >> $output_file
echo "total_retransmit: $total_retransmit" >> $output_file

node=$(($node+20))
#######################################END A ROUND
done

xgraph thXY.out -x "Number of nodes" -y "Throughput"
xgraph delayXY.out -x "Number of nodes" -y "Delay"
xgraph delXY.out -x "Number of nodes" -y "DeliveryRate"
xgraph drpXY.out -x "Number of nodes" -y "DropRate"
xgraph engXY.out -x "Number of nodes" -y "EnergyConsumption"

rm -rf *.out
rm -rf *.tr
rm -rf *.nam