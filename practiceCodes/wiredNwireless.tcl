####################################################
#network size
set x_dim 1000
set y_dim 1000

#####################################################
#this is for gridpane
set num_row 5 ;#number of row
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
#set val(chan) Channel/WirelessChannel ;# channel type
#set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
#set val(netif) Phy/WirelessPhy ;# network interface type
#set val(mac) Mac/802_11 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
#set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set opt(chan)       Channel/WirelessChannel
set opt(prop)       Propagation/TwoRayGround
set opt(netif)      Phy/WirelessPhy
#set opt(netif) 		Phy/WirelessPhy/802_15_4
set opt(mac)        Mac/802_11
#set opt(mac)		Mac/802_15_4
set opt(ifq)        Queue/DropTail/PriQueue
set opt(ll)         LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)             670   
set opt(y)              670   
set opt(ifqlen)         50
set opt(nn)             3  
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ;# routing protocol
set opt(adhocRouting)   DSDV 
set num_wired_nodes      2
set num_base_station_nodes         2

#creating ns simulator
################################################################
#Initialize ns
set ns_ [new Simulator]

# set up for hierarchical routing
  $ns_ node-config -addressType hierarchical
  AddrParams set domain_num_ 3        ;#number of domains      
  lappend cluster_num 2 1 1           ;#number of subdomains in each domain     
  AddrParams set cluster_num_ $cluster_num
  lappend eilastlevel 1 1 4 1         ;# number of nodes in each cluster     
  AddrParams set nodes_num_ $eilastlevel 

################################################################
#nam file open and enable trace flag

#Open required files such as trace file
set tracefd [open wired&wireless.tr w]
$ns_ trace-all $tracefd
#$ns_ use-newtrace 

set nf [open wire&wirelessout.nam w]
#set all animated tracefile of nf in ns
$ns_ namtrace-all $nf 

set topofile [open wired&wireless.txt "w"]

# set up topography object
set topo       [new Topography]

# god needs to know the number of all wireless interfaces
  create-god [expr $opt(nn) + $num_base_station_nodes]

proc finish {} {
	
	puts "finishing"
	global ns_ nf
 	$ns_ flush-trace
 	close $nf
 	#exec nam out.nam &
 	exit 0
}

set temp {0.0.0 0.1.0}   ;# hierarchical addresses to be used     
  for {set i 0} {$i < $num_wired_nodes} {incr i} {
      set wiredNode($i) [$ns_ node [lindex $temp $i]]
  } 



$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance [new $opt(prop)] \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF

#create base-station node
  # hier address to be used for
  #(domain).(cluster).(node) 
  set temp {1.0.0 1.0.1 1.0.2 1.0.3}   
  set base_station(0) [$ns_ node [lindex $temp 0]]
  set base_station(1) [$ns_ node 2.0.0]
  $base_station(0) random-motion 0 
  $base_station(1) random-motion 0

#provide some co-ordinates (fixed) to base station node

  $base_station(0) set X_ 10.0
  $base_station(0) set Y_ 20.0
  $base_station(0) set Z_ 0.0
  
  $base_station(1) set X_ 650.0
  $base_station(1) set Y_ 600.0
  $base_station(1) set Z_ 0.0


#configure for mobilenodes
# provide each mobilenode with
# hier address of its base-station
#configure for mobilenodes
$ns_ node-config -wiredRouting OFF



  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
            [expr $j+1]] ]
    $node_($j) base-station [AddrParams addr2id [$base_station(0) node-addr]]
  }

  #provide some co-ordinates  to wireless nodes

  $node_(0) set X_ 100.0
  $node_(0) set Y_ 20.0
  $node_(0) set Z_ 0.0
  
  $node_(1) set X_ 250.0
  $node_(1) set Y_ 200.0
  $node_(1) set Z_ 0.0

  $node_(2) set X_ 450.0
  $node_(2) set Y_ 400.0
  $node_(2) set Z_ 0.0

  #move the nodes
# set i 0
# while {$i < 3 } {

# 	$ns_ at $i "$node_($i) setdest [expr $x_dim*rand()] [expr $y_dim*rand()] 5"
# 	incr i
# };

#create links between wired and baseStation nodes
  $ns_ duplex-link $wiredNode(0) $wiredNode(1) 5Mb 2ms DropTail
  $ns_ duplex-link $wiredNode(1) $base_station(0) 5Mb 2ms DropTail
  $ns_ duplex-link $wiredNode(1) $base_station(1) 5Mb 2ms DropTail
  $ns_ duplex-link-op $wiredNode(0) $wiredNode(1) orient down
  $ns_ duplex-link-op $wiredNode(1) $base_station(0) orient left-down
  $ns_ duplex-link-op $wiredNode(1) $base_station(1) orient right-down

set tcp2 [new Agent/TCP]
  $tcp2 set class_ 2
  set sink2 [new Agent/TCPSink]
  $ns_ attach-agent $wiredNode(1) $tcp2
  $ns_ attach-agent $node_(2) $sink2
  $ns_ connect $tcp2 $sink2
  set ftp2 [new Application/FTP]
  $ftp2 attach-agent $tcp2
  $ns_ at 2 "$ftp2 start"

 for {set i 0} {$i < $opt(nn)} {incr i} {
      $ns_ initial_node_pos $node_($i) [expr 40*$i]
   }


	#simulation will finish at 4 second
 for {set i } {$i < $opt(nn) } {incr i} {
      $ns_ at 10.0000010 "$node_($i) reset";
  }
  $ns_ at 10.0000010 "$base_station(0) reset";

  $ns_ at 10.1 "puts \"NS EXITING...\" ; $ns_ halt"
puts "Starting Simulation..."
 $ns_ run
exec nam wire&wirelessout.nam &
