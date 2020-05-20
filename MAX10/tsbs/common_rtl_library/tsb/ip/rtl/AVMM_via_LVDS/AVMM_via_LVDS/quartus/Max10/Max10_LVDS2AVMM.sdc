
# Define the parallel clock period for the LVDS interface (100MHz * 5 = 500Mbps)
set clk_period 10.0


set pcb_skew 0.030 ; # uncertainty between clock and data trace skew
set ext_tccs_skew 0.250 ; # This value should be copied from the TCCS report of the interfacing device
set ext_sampling_window 0.350 ; # This value should be copied from the RKSM analysis of the interfacing device

set lvds_input_delay_max [expr $ext_tccs_skew / 2 + $pcb_skew]
set lvds_input_delay_min [expr 0 - $ext_tccs_skew / 2 - $pcb_skew]

set lvds_output_delay_max [expr $ext_sampling_window / 2 + $pcb_skew]
set lvds_output_delay_min [expr 0 - $ext_sampling_window / 2 - $pcb_skew]

# The reference clock is 1/2 the frequency that it's supposed to be, due to
#   an error in the Max10 ALTLVDS block
create_clock -name lvds2avmm_lvds_rx_clkin -period $clk_period [get_ports {lvds2avmm_lvds_rx_clkin}]
create_clock -name data_clk_virt -period [expr $clk_period / 5]

create_clock -name clk_50M -period 50.0MHz [get_ports {clk_50M}]

derive_pll_clocks
derive_clock_uncertainty

# Derive the LVDS TX clock at the output pin
create_generated_clock -name lvds2avmm_tx_clkout_clk -source [get_pins {inst|lvds2avmm|remote_bytes_to_lvds|U_LVDSTX|lvds_tx_x2_m10_inst|outclock_ddio|ddio_outa_0|dataout}] -divide_by 5 [get_ports {lvds2avmm_tx_clkout_clk}]
create_generated_clock -name lvds2avmm_tx_clkout_ddff -source [get_pins {inst|lvds2avmm|remote_bytes_to_lvds|U_LVDSTX|lvds_tx_x2_m10_inst|lvds_tx_pll|clk[0]}] [get_pins {inst|lvds2avmm|remote_bytes_to_lvds|U_LVDSTX|lvds_tx_x2_m10_inst|outclock_ddio|ddio_outa_0|dataout}]

# Create the input constraints, relating them to a 500MHz virtual clock for ease of analysis.  We assume
#   that the clock and data are edge aligned; the input delay acciunts for the PCB skew and channel to
#   channel skew of the transmitting device.
set_input_delay -clock { data_clk_virt } -min $lvds_input_delay_min [get_ports {lvds2avmm_lvds_rx_lvds*}]
set_input_delay -clock { data_clk_virt } -max $lvds_input_delay_max [get_ports {lvds2avmm_lvds_rx_lvds*}]

# Create the output constraints, relating them to the transmitted output clock.  Take into account the PCB
#   skew and sampling window of the receiving device.
set_output_delay -clock { lvds2avmm_tx_clkout_clk } -min $lvds_output_delay_min [get_ports {lvds2avmm_lvds_tx_lvds*}]
set_output_delay -clock { lvds2avmm_tx_clkout_clk } -max $lvds_output_delay_max [get_ports {lvds2avmm_lvds_tx_lvds*}]
