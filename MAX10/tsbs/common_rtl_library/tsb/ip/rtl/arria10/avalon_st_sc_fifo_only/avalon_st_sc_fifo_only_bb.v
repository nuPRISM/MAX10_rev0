
module avalon_st_sc_fifo_only (
	clk_clk,
	reset_reset_n,
	almost_empty_data,
	almost_full_data,
	out_data_data,
	out_data_valid,
	out_data_ready,
	out_data_startofpacket,
	out_data_endofpacket,
	out_data_empty,
	in_data_data,
	in_data_valid,
	in_data_ready,
	in_data_startofpacket,
	in_data_endofpacket,
	in_data_empty,
	avalon_mm_slv_address,
	avalon_mm_slv_read,
	avalon_mm_slv_write,
	avalon_mm_slv_readdata,
	avalon_mm_slv_writedata);	

	input		clk_clk;
	input		reset_reset_n;
	output		almost_empty_data;
	output		almost_full_data;
	output	[31:0]	out_data_data;
	output		out_data_valid;
	input		out_data_ready;
	output		out_data_startofpacket;
	output		out_data_endofpacket;
	output	[1:0]	out_data_empty;
	input	[31:0]	in_data_data;
	input		in_data_valid;
	output		in_data_ready;
	input		in_data_startofpacket;
	input		in_data_endofpacket;
	input	[1:0]	in_data_empty;
	input	[2:0]	avalon_mm_slv_address;
	input		avalon_mm_slv_read;
	input		avalon_mm_slv_write;
	output	[31:0]	avalon_mm_slv_readdata;
	input	[31:0]	avalon_mm_slv_writedata;
endmodule
