BEGIN {
	max_node = 100;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

	nDropPackets = 0.0;

	total_energy_consumption = 0;

	temp = 0;
	
	for (i=0; i<max_node; i++) {
		energy_consumption[i] = 0;		
	}

	total_retransmit = 0;
	for (i=0; i<max_pckt; i++) {
		retransmit[i] = 0;		
	}

	for (i=0; i<max_node; i++) {
		perNodeThrouhput[i] = 0;		
	}

}
	

{
	type=$1;	time=$2; 	source_node=$3; 	dest_node=$4;
	packet_type=$5;	
	packet_size=$6;
	flow_id=$8;
	src_addr = $9;
	dest_addr = $10;
	#seq_number=$11;
	packetid=$11;
	
	

	if(packet_type == "tcp") {
		if (packetid > idHighestPacket) idHighestPacket = packetid;
		if (packetid < idLowestPacket) idLowestPacket = packetid;

		if(time>rEndTime) rEndTime=time;
		if(time<rStartTime) rStartTime=time;

		source = int(source_node)
		potential_source = int(src_addr)

		if ( type == "+" && packet_size="1040" && (source == potential_source) ) {
			nSentPackets += 1 ;	
			rSentTime[ packetid ] = time ;
		    #printf("%15.5f\n", nSentPackets);
		}

		potential_dest = int(dest_node)
		dest = int(dest_addr)

		if ( type == "r" ) {
			#throughput
			
			
				perNodeThrouhput[potential_dest] += packet_size*8;
			if ( type == "r" && potential_dest==dest && packet_size == "1040") {
				nReceivedPackets += 1 ;		
				rReceivedTime[ packetid ] = time ;
				nReceivedBytes += packet_size;
				
				rDelay[packetid] = rReceivedTime[ packetid] - rSentTime[ packetid ];
				rTotalDelay += rDelay[packetid]; 
				#perNodeThrouhput[dest_node] += packet_size*8/rDelay[packetid];
			}
		}
	}

	if( type == "d" )
	{
		if(time>rEndTime) rEndTime=time;
		if(time<rStartTime) rStartTime=time;
		nDropPackets += 1;
	}

	
}

END {
	rTime = rEndTime - rStartTime ;
	#printf("Total time needed : %f seconds\n",rTime);
	rThroughput = (nReceivedBytes*8 / rTime);
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;
	#printf("Average Throuhput is : %f Mbps\n",rThroughput);
	#printf("Received packets : %d\n",nReceivedPackets);
	#printf("Sent packets : %d\n",nSentPackets);
	#printf("Dropped Packets : %d\n",nDropPackets);

	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
		#avg_energy_per_packet = total_energy_consumption / nReceivedPackets ;
	}

	#printf("Average End to End Delay : %f seconds\n",rAverageDelay);
	#printf("Packet Delivery Ratio : %f \n",rPacketDeliveryRatio);
	#printf("Packet Drop Ratio : %f \n",rPacketDropRatio);
	#printf("Total Delay : %f \n",rTotalDelay);
	printf( "%15.2f\n%15.5f\n%15.2f\n%15.2f\n%15.2f\n%10.2f\n%10.2f\n%10.5f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio,rTime) ;
	printf("\n");

	for (i=0; i<max_node; i++) {
		
		if(perNodeThrouhput[i]>0)
		printf("i: %15.2f\n",i,perNodeThrouhput[i]/rTime);		
	}
	

}
