`default_nettype none
module fifo_with_level_indicators 
#(
parameter device_family = "Arria V",
parameter data_width = 128,
parameter num_locations  = 256,
parameter fifo_log2_depth = $clog2(num_locations)
)
(

	input	[data_width-1:0]  data,
	input	  rdclk,
	input	  rdreq,
	input	  wrclk,
	input	  wrreq,
	output	[data_width-1:0]  q,
	output	  rdempty,
	output	  rdfull,
	output	[fifo_log2_depth-1:0]  rdusedw,
	output	  wrempty,
	output	  wrfull,
	output	[fifo_log2_depth-1:0]  wrusedw,
	input [fifo_log2_depth-1:0] stop_writing_threshold,
	input [fifo_log2_depth-1:0] stop_reading_threshold,
	input [fifo_log2_depth-1:0] start_writing_threshold,
	input [fifo_log2_depth-1:0] start_reading_threshold,
	output start_reading_now,
	output stop_reading_now,
	output start_writing_now,
	output stop_writing_now,
	input async_reset

);

assign start_reading_now = rdusedw > start_reading_threshold;
assign stop_reading_now = rdusedw < stop_reading_threshold;
assign start_writing_now = wrusedw < start_writing_threshold;
assign stop_writing_now = wrusedw > stop_writing_threshold;


parameterized_dp_fifo_with_fill_levels	
#(
.device_family(device_family),
.num_locations(num_locations),
.num_data_bits(data_width)
)
parameterized_dp_fifo_with_fill_levels_inst (
	.data ,
	.rdclk,
	.rdreq,
	.wrclk,
	.wrreq,
	.q       ,
	.rdempty ,
	.rdfull  ,
	.rdusedw ,
	.wrempty ,
	.wrfull  ,
	.wrusedw ,
	.aclr (async_reset)
	);
	
endmodule
`default_nettype wire
	