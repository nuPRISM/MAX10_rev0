


## Generated SDC file "four_lane_seriallite_and_phy.sdc.sdc"

## Copyright (C) 1991-2006 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions
## and other software and tools, and its AMPP partner logic
## functions, and any output files any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Altera Program License
## Subscription Agreement, Altera MegaCore Function License
## Agreement, or other applicable license agreement, including,
## without limitation, that your use is for the sole purpose of
## programming logic devices manufactured by Altera and sold by
## Altera or its authorized distributors.  Please refer to the
## applicable agreement for further details.

# MODULE_NAME = four_lane_seriallite_and_phy
# COMPANY     = Altera Corporation
# WEB         = www.altera.com
#
# FUNCTIONAL_DESCRIPTION :
#    SLITE-II SDC Constraint file. Used by Quartus II TimeQuest.
#    To use this constraint file (assuming the name of this file is four_lane_seriallite_and_phy.sdc ):
#       - create a Quartus II project
#       - copy this constraint file into the project directory
#       - open the project
#       - run this constraint file
#           in the TimeQuest tool:  >open four_lane_seriallite_and_phy.sdc
#           or,
#           enable TimeQuest, and add / four_lane_seriallite_and_phy.sdc to the filelist.
#       - compile the project as usual
#
#
#    This script is intended to be a guide. It is highly possible
#    that due how the design is instantiated and other designs
#    in your project may require some edits to this script in
#    order to ensure proper timing constraints.

## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 6.1 11/30/2006 SJ Full Version"

## DATE    "Fri Sep 01 15:30:40 2006"

##
## DEVICE  "EP2SGX90FF1508C3"
##


#**************************************************************
# Time Information
#**************************************************************

#set_time_format -unit ns -decimal_places 3         (This is the default)


#**************************************************************
# Set Clock Names
#*************************************************************
   set trefclk_name "trefclk"

#**************************************************************
# Create Clock
#*************************************************************

derive_pll_clocks

derive_clock_uncertainty

#derive_clocks -period 8.000


## The clocks below are at the core top level. You may need to adjust this section
## accordingly once the SLITE2 design is part of a larger design.

create_clock -name $trefclk_name -period 8.000 -waveform { 0.000 4.000 } [get_ports $trefclk_name]

#**************************************************************
# Create Generated Clock
#**************************************************************


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

#set_input_delay -clock $trefclk_name 5 [get_ports *]

#**************************************************************
# Set Output Delay
#**************************************************************

#set_output_delay -clock $trefclk_name 5 [get_ports *]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************


     set_false_path -from [get_keepers *four_lane_seriallite_and_phy*link_up]
set_false_path -from [get_keepers *four_lane_seriallite_and_phy*reset_d[2]*]
        set_clock_groups -asynchronous -group { *four_lane_seriallite_and_phy*transmit_pcs0|clkout } -group { *four_lane_seriallite_and_phy*receive_pcs0|clkout }

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************
# Generically Constrain the input I/O path

#set_max_delay -from [all_inputs] -to [all_registers] 10

# Generically Constrain the Output I/O path

#set_max_delay -from [all_registers] -to [all_outputs] 10


#**************************************************************
# Set Minimum Delay
#**************************************************************


