
module clock_cross_multiple_synced_avst
(
	multiple_synced_st_streaming_interfaces avst_in,
	multiple_synced_st_streaming_interfaces avst_out
);

	genvar i;

		generate
	     			for (i = 0; i < avst_out.get_num_channels(); i++)
					begin : make_per_channel_data_clock_cross
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(avst_out.get_num_data_bits()) 
							)
							mcp_sample_since_reset_count
							(
							   .in_clk(avst_in.clk),
							   .in_valid(avst_in.valid),
							   .in_data(avst_in.data[i),
							   .out_clk(avst_out.clk),
							   .out_valid(),
							   .out_data(avst_out.data[i])
							 );	
					end		 
			              