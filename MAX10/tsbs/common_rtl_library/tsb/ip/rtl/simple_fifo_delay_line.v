`default_nettype none
module simple_fifo_delay_line
#(
 parameter device_family = "Stratix IV",
 parameter num_locations  = 256,
 parameter num_data_bits = 128,
 parameter the_delay = num_locations-2,
 parameter num_usedw_bits = $clog2(num_locations)
)
(
	async_clear_fifo,
	clock,
	data_in,
	data_in_valid,	
	data_out,
	usedw,
    delay_achieved	
); 
	
	input	async_clear_fifo;
	input	clock;
	input	[num_data_bits-1:0]  data_in;
	input	data_in_valid;
	output	[num_data_bits-1:0]   data_out;
	output	[num_usedw_bits-1:0]  usedw;
	output  delay_achieved;

wire almost_full;
assign delay_achieved = almost_full;


parameterized_single_clk_fifo_with_fill_levels
#(
 .device_family(device_family),
 .num_locations(num_locations),
 .num_data_bits(num_data_bits),
 .almost_full_value(the_delay)
)
parameterized_single_clk_fifo_with_fill_levels_inst
(
	.aclr (async_clear_fifo),
	.clock(clock),
	.data (data_in),
	.rdreq(almost_full),
	.wrreq(data_in_valid),
	.almost_empty(),
	.almost_full(almost_full),
	.empty(),
	.full(),
	.q(data_out),
	.usedw(usedw)	
);
	
endmodule
`default_nettype wire