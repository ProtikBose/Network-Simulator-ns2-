set ns [new Simulator]

#different colors for different dataflow
$ns color 1 Blue
$ns color 2 Red

#open trace files
set tracefile1 [open trace.tr w]
$ns trace-all $tracefile1
set namfile1 [open trace.nam w]
$ns namtrace-all $namfile1

#define a finish procedure
proc finish {} {
	global ns tracefile1 namfile1
	$ns flush-trace 
	close $tracefile1
	close $namfile1
	exec nam trace.nam &
	exit 0 
}

#create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#...

#create links between nodes
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns simplex-link $n2 $n3 0.3Mb 100ms DropTail
$ns simplex-link $n3 $n2 0.3Mb 100ms DropTail
$ns duplex-link $n3 $n4 0.5Mb 40ms DropTail
$ns duplex-link $n3 $n5 0.5Mb 30ms DropTail
#...

#give nodes positions
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns simplex-link-op $n2 $n3 orient right
$ns simplex-link-op $n3 $n2 orient left
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n3 $n5 orient right-down
#...

#set queue limit
$ns queue-limit $n0 $n2 20
#...

#setup a tcp connection
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
$ns connect $tcp $sink
$tcp set fid_ 2
$tcp set packetSize_ 552

#setup ftp over tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#run tcp transaction
$ns at 1.0 "$ftp start"
$ns at 3.0 "$ftp stop"
$ns at 1.2 "$ns trace-annotate \"ftp transfer\""

$ns at 6.0 "finish"

$ns run
