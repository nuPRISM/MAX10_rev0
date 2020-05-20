#-----------------------------------------------------------
#create master clock
#-----------------------------------------------------------

#FPGA clock pin name connected to S/LABS HBMC refrence clk (in_clk)
derive_pll_clocks -create_base_clocks

#-----------------------------------------------------------
#Set clock path
#-----------------------------------------------------------

if {internal_pll == 1} {
   set hyperbus_clk    "*U_SLL_HBC_T001_PLL|altpll_component|*|*|clk[0]"
   set core_clk        "*U_SLL_HBC_T001_PLL|altpll_component|*|*|clk[3]"
} else {
   set hyperbus_clk    "*altpll_0|*|*|clk[0]"
   set core_clk        "*altpll_0|*|*|clk[3]"
}


#-----------------------------------------------------------
#output clock signal name
#-----------------------------------------------------------
   if {"device_family" == "MAX 10" || "device_family" == "Max 10"} {
    set clkout_pin_name "*|U_IO|U_CLK0|*|*|output_buf.obuf\|o"
   } else { 
    set clkout_pin_name "*|U_IO|U_CLK0|*|*|ddio_outa\[0\]\|dataout"    
   }


#-----------------------------------------------------------
# Output delay
#-----------------------------------------------------------
set HB_clk_ports     [get_ports -no_case HB*clk*]
set HB_csn_ports     [get_ports -no_case HB*cs* ]

set_max_delay -from [get_registers *] -to ${HB_csn_ports}   [expr (0.6* dqs_clk_freq_in_ns)]
set_max_delay -from [get_registers *] -to ${HB_clk_ports}   [expr (0.6* dqs_clk_freq_in_ns)]

#-----------------------------------------------------------
# Board parameters
#-----------------------------------------------------------
set dqs_in_max_dly     0.51  ;#RWDS input maximum delay
set dqs_in_min_dly    -0.51  ;#RWDS input minimim delay

#-----------------------------------------------------------
#virtual clock with same phase as real clock due to edge aligned input
#-----------------------------------------------------------
create_clock -name virt_rwds_clk -period dqs_clk_freq_in_ns

#derive clocks and clock uncertainty
derive_clock_uncertainty

#get rwds in port names
set rwds_in_ports [get_ports -no_case -nowarn rwds_clk_pin_name]
set rwds_num_pins [ get_collection_size $rwds_in_ports]
set rwds_in_port_list ""
foreach_in_collection name_id  $rwds_in_ports {
    set port_name [get_port_info -name $name_id]
    lappend rwds_in_port_list $port_name
}

#get rwds out port names
set rwds_out_ports [get_ports -no_case -nowarn HB*rwds]
set rwds_out_port_list ""
foreach_in_collection name_id  $rwds_out_ports {
    set port_name [get_port_info -name $name_id]
    lappend rwds_out_port_list $port_name
}


#get Hbus clk0p or HB_CLK0 out port names
set clk_out_ports [get_ports -no_case -nowarn HB*_clk0]

if { [get_collection_size $clk_out_ports] < 1} {
set clk_out_ports [get_ports -no_case -nowarn HB*_clk0p]
 }
   

set clk_out_port_list ""
foreach_in_collection name_id  $clk_out_ports {
    set port_name [get_port_info -name $name_id]
    lappend clk_out_port_list $port_name
}


#get clk_out_source pin names
set clk_out_source [get_pins -no_case -compatibility_mode $clkout_pin_name]
set clk_out_source_list ""
foreach_in_collection name_id  $clk_out_source {
    set pin_name [get_pin_info -name $name_id]
    lappend clk_out_source_list $pin_name
}

#get dq port names
set dq_port_list ""
foreach_in_collection name_id [get_ports -no_case -nowarn HB*dq[*]] {
    set port_name [get_port_info -name $name_id]
    lappend dq_port_list $port_name
}

#
#loop over number of instantiated controllers
for {set hb_cs 0} {$hb_cs < $rwds_num_pins} {incr hb_cs} {

   #
   #set rwds clock pin as either RWDS or RWDSC
   #
   set HB_rwds_in_ports   [lindex $rwds_in_port_list  $hb_cs]
   set HB_rwds_out_ports  [lindex $rwds_out_port_list $hb_cs]
   set HB_clk_out_ports   [lindex $clk_out_port_list $hb_cs]
   set HB_clk_out_source  [lindex $clk_out_source_list $hb_cs]
   set rwds_clk_name      rds_clk${hb_cs}
   set clkout_clk_name    clkout${hb_cs}

   #-----------------------------------------------------------
   #virtual input clock with same phase as real clock due to edge aligned input
   #-----------------------------------------------------------
   create_clock -name $rwds_clk_name  -period dqs_clk_freq_in_ns ${HB_rwds_in_ports}

   #-----------------------------------------------------------
   #RWDS timing
   #-----------------------------------------------------------
   set dq_start_idx [expr 8*$hb_cs]
   set dq_end_idx   [expr $dq_start_idx+8]

   for {set dq_idx $dq_start_idx} {$dq_idx < $dq_end_idx} {incr dq_idx} {
      set HB_dq_port  [lindex $dq_port_list $dq_idx]

      set_input_delay -clock [get_clocks virt_rwds_clk]             -max ${dqs_in_max_dly} ${HB_dq_port}
      set_input_delay -clock [get_clocks virt_rwds_clk] -clock_fall -max ${dqs_in_max_dly} ${HB_dq_port} -add_delay

      set_input_delay -clock [get_clocks virt_rwds_clk]             -min ${dqs_in_min_dly} ${HB_dq_port} -add_delay
      set_input_delay -clock [get_clocks virt_rwds_clk] -clock_fall -min ${dqs_in_min_dly} ${HB_dq_port} -add_delay

   }
   set_multicycle_path -setup -end -rise_from [get_clocks virt_rwds_clk] -rise_to [get_clocks $rwds_clk_name] 0
   set_multicycle_path -setup -end -fall_from [get_clocks virt_rwds_clk] -fall_to [get_clocks $rwds_clk_name] 0

   set_false_path  -fall_from [get_clocks virt_rwds_clk] -rise_to [get_clocks $rwds_clk_name] -setup
   set_false_path  -rise_from [get_clocks virt_rwds_clk] -fall_to [get_clocks $rwds_clk_name] -setup
   set_false_path  -fall_from [get_clocks virt_rwds_clk] -fall_to [get_clocks $rwds_clk_name] -hold
   set_false_path  -rise_from [get_clocks virt_rwds_clk] -rise_to [get_clocks $rwds_clk_name] -hold

#   set_max_delay -from ${HB_rwds_in_ports} -to [get_registers {*in_refresh180}] 6

   #-----------------------------------------------------------
   #Output Delay Constraint -  HB_CLK0-HB_DQ 
   #-----------------------------------------------------------

   create_generated_clock -name $clkout_clk_name  -source ${HB_clk_out_source}  -divide_by 1 -multiply_by 1 -invert ${HB_clk_out_ports}  

   
   set_output_delay -clock [get_clocks $clkout_clk_name] -min -1.000 ${HB_dq_port}
   set_output_delay -clock [get_clocks $clkout_clk_name] -max  1.000 ${HB_dq_port}
   set_output_delay -clock [get_clocks $clkout_clk_name] -min -1.000 ${HB_dq_port} -clock_fall -add_delay
   set_output_delay -clock [get_clocks $clkout_clk_name] -max  1.000 ${HB_dq_port} -clock_fall -add_delay

   set_multicycle_path -from {*U_HBC|*|dq_io_tri} -to ${HB_dq_port} -hold -end 2

   #-----------------------------------------------------------
   #setting false paths from RWDS to other clocks
   #-----------------------------------------------------------

   set_false_path -from [get_clocks $rwds_clk_name] -to   [get_clocks ${hyperbus_clk}]
   set_false_path -to   [get_clocks $rwds_clk_name] -from [get_clocks ${hyperbus_clk}]

   if {single_clock_mode == "false"} {
     set_false_path -from [get_clocks $rwds_clk_name] -to   [get_clocks ${core_clk}]
     set_false_path -to   [get_clocks $rwds_clk_name] -from [get_clocks ${core_clk}]
   }
   #-----------------------------------------------------------
   #setting false paths from Core clock to hyperbus clock
   #-----------------------------------------------------------
   if {single_clock_mode == "false"} {
     set_false_path  -from  [get_clocks ${hyperbus_clk}]  -to  [get_clocks ${core_clk}]
     set_false_path  -from  [get_clocks ${core_clk}]      -to  [get_clocks ${hyperbus_clk}]
  }

#   set_multicycle_path -from ${HB_rwds_in_ports} -to [get_registers {*|*|*|rwds_in_0}] -setup -end 2

}

#-----------------------------------------------------------
#setting false paths from inclk to reset 
#-----------------------------------------------------------
set_false_path -from {*iavs0_rstn_*}
set_false_path -from {*hbmc_reset_ff3*}

set_false_path -to   {*iavs0_rstn_*}

