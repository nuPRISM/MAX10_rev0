module export_clk_reset(

	input  wire tx_clk,
	input  wire tx_rstn,
	input  wire rx_clk,
	input  wire rx_rstn,
	input  wire reconfig_clk,
	input  wire reconfig_rst,
	input  wire clkout,
	input  wire clkout_rstn,

	
	output  wire expt_tx_clk,
	output  wire expt_tx_rstn,
	output  wire expt_rx_clk,
	output  wire expt_rx_rstn,
	output  wire expt_reconfig_clk,
	output  wire expt_reconfig_rst,
	output  wire expt_clkout,
	output  wire expt_clkout_rstn

	
);

assign expt_tx_clk  = tx_clk; 
assign expt_tx_rstn = tx_rstn; 
assign expt_rx_clk  = rx_clk; 
assign expt_rx_rstn = rx_rstn; 

assign expt_reconfig_clk = reconfig_clk;
assign expt_reconfig_rst = reconfig_rst;
assign expt_clkout       = clkout;
assign expt_clkout_rstn  = clkout_rstn;


endmodule
