##############################################
#
# This script need to be placed in 
# project_directory/hypernios/testbench/mentor
#
#

#
# replace testbench
# Add HyperRAM/HyperFlash sdf file
#
file copy -force ../../../ip/SLL_Hyperbus_controller/sim/hypernios_tb.v ../hypernios_tb/simulation/
file copy -force ../../../ip/SLL_Hyperbus_controller/sim/IS66WVH16M8ALL_Rev0_4.v  ./

#
#Copy Synaptic Labs HyperbusController Simulation model
#
#check if simulation directory exists
#
if { [file exists ./sll_hyperbus_controller_top_mentor] == 0} {               
    file copy -force ../../../ip/SLL_Hyperbus_controller/sll_hyperbus_controller_top_mentor  ./sll_hyperbus_controller_top_mentor
}

#execute script
source msim_setup.tcl

#compile devices
vlog IS66WVH16M8ALL_Rev0_3.v +define+S60

#
#set additiona elaboration parameters
#
#include Synaptic Labs' Hyperbus Controller Simulation Library (sll_hyperbus_controller_top_mentor)
#include HyperRAM sdf file
#
set USER_DEFINED_ELAB_OPTIONS "-sdfnoerror -L sll_hyperbus_controller_top_mentor "

#
#compile design and load testbench
#
ld

