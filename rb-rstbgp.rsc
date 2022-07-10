#
# Name of the script RB-RSTBGP (rb-rstbgp.rsc) vers. 2022071000
# this script is for reset stalled bgp sessions of the RouterBoard
# Copyright Igor Alov (alov.igor@gmail.com)
#
# https://github.com/IgorAlov/rb-rstbgp.rsc

:local timecheck 10m
/file remove [/file find name=rb-rstbgp.rsc]
/system script add dont-require-permissions=no name=rb-rstbgp.rsc policy=read,write source=\
{
:local timerst 1s
/routing bgp peer {
   :foreach i in [find (state="opensent" or state="idle") and disabled=no] do={
      :log warning ("Turning OFF stalled BGP Peer: $([get $i name])")
      disable $i
      :delay $timerst
      :log warning ("Turning ON stalled BGP Peer: $([get $i name])")
      enable $i
      }
   }
/
}
/system scheduler add interval=$timecheck name=rb-rstbgp.rsc on-event=rb-rstbgp.rsc\
   policy=read,write \
   start-date=jan/01/2019 start-time=10:00:00
/file remove [/file find name=rb-rstbgp.rsc]
