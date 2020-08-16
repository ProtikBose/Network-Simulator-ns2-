#network size
set x_dim 1000
set y_dim 1000

#number of nodes and positions
set num_row 10 ;#number of row
set num_col 5 ;#number of column

#number and other attributes of flow
set time_duration 5 ;#50
set start_time 10.0 ;#100
set parallel_start_gap 1.0

#energy parameters
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules
set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			;#Stargate (802.11b)
set val(txpower_11) 1425e-3			;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
set val(transitiontime_11) 3			;#Stargate (802.11b)

#number of different flows
set num_parallel_flow 20
set num_cross_flow 10
set num_random_flow 0

set grid 0
set extra_time 10 ;#10
set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

set tcp_src Agent/UDP ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
set tcp_sink Agent/Null ;# Agent/TCPSink or Agent/TCPSink/Sack1

#protocols and models for different layers
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ;# routing protocol

#initialize ns
set ns [new Simulator]

#initialize trace files
set tracefile1 [open staticout.tr w]
$ns trace-all $tracefile1
#$ns use-newtrace ;# use the new wireless trace file format

set namfile1 [open staticout.nam w]
$ns namtrace-all-wireless $namfile1 $x_dim $y_dim

#set topology file
set topofile [open "topo.txt" w]

# set up topography object
set topo [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

#helps us find the distance between two routers
#GoD object keeps track of global info like topology, next hop
create-god [expr $num_row * $num_col] 

#node-config
$ns node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
			 -energyModel $val(energymodel_11) \
			 -idlePower $val(idlepower_11) \
			 -rxPower $val(rxpower_11) \
			 -txPower $val(txpower_11) \
          		 -sleepPower $val(sleeppower_11) \
          		 -transitionPower $val(transitionpower_11) \
			 -transitionTime $val(transitiontime_11) \
			 -initialEnergy $val(initialenergy_11)

#create nodes 
puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns node]
	#static network
	$node_($i) random-motion 0 
}

#set positions for nodes
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];

	set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
	set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
};



#create flows and associate them with nodes
#parallel flow
#sources and sinks created(Agents)
for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow]} {incr i} {
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns color $i Blue
	} else {
		$ns color $i Red
	}
} 

#parallel flow
#sources and sinks are attached with nodes
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	set null_node [expr (($num_col)*($num_row-1))-$i-1];#CHNG
	$ns attach-agent $node_($udp_node) $udp_($i)
  	$ns attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 



#udp sources are connected
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns connect $udp_($i) $null_($i)
}
#cbr application attached
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

#cbr started
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}

#tell nodes when simulation ends
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns at [expr $start_time+$time_duration] "$node_($i) reset";
}
$ns at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
$ns at [expr $start_time+$time_duration +$extra_time] "$ns nam-end-wireless [$ns now]; puts \"NS Exiting...\"; $ns halt"

$ns at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
	global ns tracefile1 namfile1 topofile 
	#global ns_ topofile
	$ns flush-trace
	close $tracefile1
	close $namfile1
	close $topofile
    exec nam staticout.nam &
        exit 0
}

#defining nodes for NAM
for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns run 