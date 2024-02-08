# connect -host localhost
connect

targets
targets -set -filter {name =~ "ARM*#0"}
rst

fpga /home/yiruiz2/Documents/OpenSSDWorkspace/OpenSSDBoard/OpenSSD2.bit
loadhw /home/yiruiz2/Documents/OpenSSDWorkspace/OpenSSDBoard/system.hdf
source /home/yiruiz2/Documents/OpenSSDWorkspace/OpenSSDBoard/ps7_init.tcl

ps7_init
ps7_post_config
dow /home/yiruiz2/Documents/OpenSSDWorkspace/OpenSSD/Debug/OpenSSD.elf
con

