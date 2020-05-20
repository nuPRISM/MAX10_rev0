# Define the parallel clock period for the LVDS interface (100MHz * 5 = 500Mbps)
set clk_period 10.0

# The reference clock is 1/2 the frequence that it's supposed to be, due to
#   an error in the Max10 ALTLVDS block
create_clock -name lvds_refclk -period [expr $clk_period * 2.0] [get_ports {lvds_refclk}]
create_clock -name data_clk_virt -period [expr $clk_period / 5]
derive_pll_clocks
derive_clock_uncertainty