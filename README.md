# Network-Simulator-ns2-

Details about ns2 can be found [here](https://en.wikipedia.org/wiki/Ns_(simulator)). Here we have used ns-2.35 . 

We have modified the existing ns2 model for wired and wireless network by modifying RTT (Round Trip Time ) calculation, the Congestion Control Algorithm and the RTO values. After
that we compared the new values with the previous one . For our wired network, we don’t have any drop packets .That’s why, changing RTT calculations doesn’t put any difference with the previous value. But after changing the congestion control and RTO default values , we found a massive positive change with previous value.

On the other hand, RTT calculations ,congestion control and RTO default values all make
difference for the wireless network . Though for some nodes , some values decline . But for
most of the cases, values changes positively. Although throughput declined by a slight margin, we witnessed positive change regarding delay, drop ratio and delivery ratio(after modifying RTT calculations). When we modified congestion control along with RTT calculations and RTO values, we saw slight increase in throughput. Also delay increased. Delivery ratio decreased. Drop ratio increased in most cases.

Details about our modification can be found from "Report.pdf".

## Reference

1) Elbery, Ahmed. (2005). A Modification to Swifter Start Algorithm for TCP Congestion Control. 

2) Roy, A. (2006). MODIFICATION OF CONGESTION CONTROL ALGORITHM FOR TCP AND ITS EXTENSION TO EXPLICIT RATE ADJUSTMENT ALGORITHM.

3) Ahmad, Z., & Abd Jalil, K. (2012, December). Performance evaluation on modified AODV protocols. In 2012 IEEE Asia-Pacific Conference on Applied Electromagnetics (APACE) (pp. 158-163). IEEE.

4) Saha, S., Roy, U., & Sinha, D. Modified AODV with double ended queue (dqAODV) with reduced overhead.

5) Issariyakul, T., & Hossain, E. (2009). Introduction to network simulator 2 (NS2). In Introduction to network simulator NS2 (pp. 1-18). Springer, Boston, MA.
