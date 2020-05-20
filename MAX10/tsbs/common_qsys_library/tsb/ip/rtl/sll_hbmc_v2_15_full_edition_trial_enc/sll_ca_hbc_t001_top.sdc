#-----------------------------------------------------------
#create master clock
#-----------------------------------------------------------

#FPGA clock pin name connected to S/LABS HBMC refrence clk (in_clk)
derive_pll_clocks -create_base_clocks

#-----------------------------------------------------------
#Set clock path
#-----------------------------------------------------------
set hyperbus_clk    "*|*|*|U_SLL_HBC_T001_PLL|altpll_component|auto_generated|*|clk[0]"
set core_clk        "*|*|*|U_SLL_HBC_T001_PLL|altpll_component|auto_generated|*|clk[3]"
set rds_clk         "*|*|*|rds_clk"

set HB_clk_ports     [get_ports -no_case HB*clk*]
set HB_csn_ports     [get_ports -no_case HB*cs*]
set HB_rwds_ports    [get_ports -no_case HB*rwds]
set HB_dq_ports      [get_ports -no_case HB*dq[*]]

#-----------------------------------------------------------
# Board parameters
#-----------------------------------------------------------
set dqs_in_max_dly     0.5  ;#RWDS input maximum delay
set dqs_in_min_dly    -0.5  ;#RWDS input minimim delay

#-----------------------------------------------------------
#virtual clock with same phase as real clock due to edge aligned input
#-----------------------------------------------------------
create_clock -name virt_rwds_clk -period dqs_clk_freq_in_ns
create_clock -name rwds_clk      -period dqs_clk_freq_in_ns ${HB_rwds_ports}

#derive clocks and clock uncertainty
derive_clock_uncertainty
derive_pll_clocks

#-----------------------------------------------------------
#RWDS timing
#-----------------------------------------------------------
set_input_delay -clock [get_clocks virt_rwds_clk]             -max ${dqs_in_max_dly} ${HB_dq_ports}
set_input_delay -clock [get_clocks virt_rwds_clk] -clock_fall -max ${dqs_in_max_dly} ${HB_dq_ports} -add_delay

set_input_delay -clock [get_clocks virt_rwds_clk]             -min ${dqs_in_min_dly} ${HB_dq_ports} -add_delay
set_input_delay -clock [get_clocks virt_rwds_clk] -clock_fall -min ${dqs_in_min_dly} ${HB_dq_ports} -add_delay

set_multicycle_path -setup -end -rise_from [get_clocks virt_rwds_clk] -rise_to [get_clocks rwds_clk] 0
set_multicycle_path -setup -end -fall_from [get_clocks virt_rwds_clk] -fall_to [get_clocks rwds_clk] 0

set_false_path  -fall_from [get_clocks virt_rwds_clk] -rise_to [get_clocks rwds_clk] -setup
set_false_path  -rise_from [get_clocks virt_rwds_clk] -fall_to [get_clocks rwds_clk] -setup
set_false_path  -fall_from [get_clocks virt_rwds_clk] -fall_to [get_clocks rwds_clk] -hold
set_false_path  -rise_from [get_clocks virt_rwds_clk] -rise_to [get_clocks rwds_clk] -hold

set_max_delay -from [get_registers *] -to ${HB_csn_ports}   [expr 0.6* dqs_clk_freq_in_ns]
set_max_delay -from [get_registers *] -to ${HB_clk_ports}   [expr 0.6* dqs_clk_freq_in_ns]


#-----------------------------------------------------------
#setting false paths from RWDS to other clocks
#-----------------------------------------------------------

set_false_path -from [get_clocks {rwds_clk}] -to   [get_clocks ${hyperbus_clk}]
set_false_path -to   [get_clocks {rwds_clk}] -from [get_clocks ${hyperbus_clk}]

if {single_clock_mode == "false"} {
  set_false_path -from [get_clocks {rwds_clk}] -to   [get_clocks ${core_clk}]
  set_false_path -to   [get_clocks {rwds_clk}] -from [get_clocks ${core_clk}]
}
#-----------------------------------------------------------
#setting false paths from Core clock to hyperbus clock
#-----------------------------------------------------------
if {single_clock_mode == "false"} {
  set_false_path  -from  [get_clocks ${hyperbus_clk}]  -to  [get_clocks ${core_clk}]
  set_false_path  -from  [get_clocks ${core_clk}]      -to  [get_clocks ${hyperbus_clk}]
}  


#-----------------------------------------------------------
#setting false paths from inclk to reset clocked by clk_270
#-----------------------------------------------------------
set_false_path -from {*iavs0_rstn_*}
set_false_path -from {*iavs0_270_rstn_*}

set_false_path -to {*iavs0_rstn_*}
set_false_path -to {*iavs0_270_rstn_*}

set_false_path -from {*|*|*|altera_reset_synchronizer_int_chain_out} -to {*csn_mux_h_r}


#report_path -from [get_ports {HB_RWDS}]  -npaths 1 -panel_name {Report Path} -multi_corner
#report_path -from [get_ports {HB_dq[*]}] -npaths 1 -panel_name {Report Path} -multi_corner



