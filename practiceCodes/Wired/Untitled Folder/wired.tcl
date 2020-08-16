####################################################
#network size
set x_dim 1000
set y_dim 1000

#####################################################
#this is for gridpane
set num_row 10 ;#number of row
set num_col 5 ;#number of column
set cbr_size 1000
set cbr_rate 11.0Mb
set cbr_interval 1;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second

###################################################
#Number and other attributes of flows
#parallel flow
set parallel_start_gap 1.0
#cross flow
set cross_start_gap 1.0
set num_parallel_flow 20
set num_cross_flow 10
set num_random_flow 0
set flowNo [lindex $argv 1]
set ftp_interval [lindex $argv 2]
#########################################################
#time
set time_duration 5 ;#50
set start_time 10 ;#100
set extra_time 2 ;#10

#############################################################
#ENERGY PARAMETERS
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules
set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			;#Stargate (802.11b)
set val(txpower_11) 1425e-3			;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
set val(transitiontime_11) 3			;#Stargate (802.11b)

###############################################################
#Protocols and models for different layers
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

set tcp_src Agent/TCP ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1

#creating ns simulator
################################################################
#Initialize ns
set ns_ [new Simulator]

################################################################
#nam file open and enable trace flag

#Open required files such as trace file
set tracefd [open staticout.tr w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace 

set nf [open out.nam w]
#set all animated tracefile of nf in ns
$ns_ namtrace-all $nf 

proc finish {} {
	
	puts "finishing"
	global ns_ nf
 	$ns_ flush-trace
 	close $nf
 	#exec nam out.nam &
 	exit 0
}
 #creating nodes

puts [expr [lindex $argv 0]]
set limit [expr [lindex $argv 0]]
set num_col [expr $limit/10]

puts "start node creation"
for {set i 0} {$i < $limit} {incr i} {
	set node_($i) [$ns_ node]
	#this will help to be static
	#$node_($i) random-motion 0
}

puts "creating link"
for {set i 0} {$i < $limit} {incr i} {
	#if {$i < [expr $num_col-1] } {
        	$ns_ duplex-link $node_($i) $node_([expr ($i+1)%$limit]) 1Mb 10ms DropTail
	#}
	#$ns_ duplex-link $node_($i) $node_([expr ($i+$num_row)%$limit]) 1Mb 10ms DropTail
       # $ns_ queue-limit $node_($i) $node_([expr ($i+1)%$limit]) 50
}

#positioning

# set x_start [expr $x_dim/($num_col*2)];
# set y_start [expr $y_dim/($num_row*2)];
# set i 0;
# while {$i < $num_row } {
# #in same column
#     for {set j 0} {$j < $num_col } {incr j} {
# #in same row
# 	set m [expr $i*$num_col+$j];
# #	$node_($m) set X_ [expr $i*240];
# #	$node_($m) set Y_ [expr $k*240+20.0];

# 	set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
# 	set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	
# 	$node_($m) set X_ $x_pos;
# 	$node_($m) set Y_ $y_pos;
# 	$node_($m) set Z_ 0.0
# #	puts "$m"
# 	#puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
#     }
#     incr i;
# }; 



 #creating traffic
 #this is a tcp protocol
 #tcp is a connection based protocol, so we need source and dest.

 set src [new Agent/TCP]
 
 $src set rate_ 1mb
 $ns_ attach-agent $node_(0) $src

 set sink [new Agent/TCPSink]
 $ns_ attach-agent $node_([expr $limit/4+$limit/2]) $sink
#$ns_ attach-agent $node_(75) $sink

 $ns_ connect $src $sink

 #ftp protocol 
 #this is an application layer

 set ftp [new Application/FTP]
 $ftp attach-agent $src
 $ftp set type_ FTP  

 #simulation
 #simulation will start at 0.1 second
 $ns_ at 0.1 "$ftp start" 
 #simulation start will work at 3 second
 $ns_ at 3 "$ftp start"
 #simulation will finish at 4 second
 $ns_ at 4 "finish"

 $ns_ run
